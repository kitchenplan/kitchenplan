require 'spec_helper'
require 'ohai'
require 'kitchenplan'

describe Kitchenplan::Config do
	let(:fake_ohai) do
		{
			"fqdn" => "hostname.example.org",
			"hostname" => "hostname",
			"machinename" => "machinename",
			"platform" => "example-platform",
			"platform_version" => "example-platform-1.0",
			"platform_family" => "example",
			"data" => {}
		}
	end
	let(:fake_options) do
		{
			:debug=>false, :config_dir=>"config/", :chef=>true
		}
	end
	let(:kcf) do
		kcf = Kitchenplan::Config.new(ohai=fake_ohai,parse_configs=false,config_path=FIXTURE_CONFIG_DIR)
		kcf.stub(:detect_platform)
		kcf
	end
	describe "#initialize" do
		[true, false].each do |configs|
			context "when parse_configs is #{configs}" do
				it "run or don't run do_parse_configs" do
					Kitchenplan::Config.any_instance.stub(:do_parse_configs => true, :detect_platform => true)
					if configs == true
						expect_any_instance_of(Kitchenplan::Config).to receive :do_parse_configs
						ki = Kitchenplan::Config.new(ohai=fake_ohai,parse_configs=true)
					else
						expect_any_instance_of(Kitchenplan::Config).not_to receive :do_parse_configs
						kci = Kitchenplan::Config.new(ohai=fake_ohai,parse_configs=false).stub(:do_parse_configs)
					end
				end
			end
		end
	end
	describe "#do_parse_configs" do
		let(:kci) { Kitchenplan::Config.new(ohai=fake_ohai,parse_configs=false) }
		context "with default parameters" do
			path_value="config"

			it "sets self.config_path" do
				kci.do_parse_configs(config_path=path_value)
				expect(kci.config_path).to eq path_value
			end
		end
		context "with custom parameters" do
			path_value=FIXTURE_CONFIG_DIR
			it "sets self.config_path" do
				kci.do_parse_configs(config_path=path_value)
				expect(kci.config_path).to eq path_value
			end
		end
	end
	describe "#parse_default_config" do
		it "loads and parses the fixture default config" do
			expect(kcf.parse_default_config() ).to include "attributes"
		end
	end
	describe "#parse_people_config" do
		it "attempts to parse a config file based on the user's name" do
			kcf.stub(:parse_config => {})
			kcf.parse_people_config()
			expect(kcf).to have_received(:parse_config).with("#{kcf.config_path}/people/#{Etc.getlogin}.yml")
		end
		it "loads people/roderik.yml if the regular user load attempt fails" do
			Etc.stub(:getlogin => "nonexistent")
			Kitchenplan::Log.stub(:warn)
			expect(kcf).to receive(:parse_config).with(/nonexistent.yml/) { raise LoadError }
			expect(kcf).to receive(:parse_config).with(/roderik.yml/)
			kcf.parse_people_config()
		end

	end
	describe "#parse_group_configs" do
		default_group_values = [ ['group1'], [] ]
		default_people_values = [ ['group2'], [] ]
		default_group_values.each do |dgv|
			default_people_values.each do |dpv|
				context "with default group of #{dgv} and people group of #{dpv}" do
					it "parses the config fixture successfully" do
						kcf.instance_variable_set(:@default_config, { "groups" => dgv})
						kcf.instance_variable_set(:@people_config, { "groups" => dpv})
						desired_output = (dgv | dpv).flatten
						kcf.parse_group_configs()
						expect(kcf.group_configs.keys).to eq desired_output
					end
				end
			end
		end
	end
	describe "#parse_group_config" do
		groups = %w{ group1 group2 }.each do |grp|
			context "with group file #{grp}"  do
				it "parses #{grp}.yml" do
					kcf.parse_group_config(grp)
					expect(kcf.group_configs[grp]).to be_kind_of(Hash)
				end
			end
			context "with a nested group" do
				it "parses group1.yml and group2.yml" do
					kcf.parse_group_config("group3")
					expect(kcf.group_configs).to include 'group3', 'group2', 'group3' 
				end
			end
		end
	end
	describe "#parse_config" do
		it "returns an empty hash when a nonexistent file param is passed" do
			expect(kcf.parse_config("/nonexistent/file/this/will/never/pass.yml")).to eql({})
		end
		it "raises an exception if it encounters a YAML parse error on a file" do
			Kitchenplan::Log.stub(:error)
			expect { kcf.parse_config("#{kcf.config_path}/bad.yml") }.to raise_error(StandardError, /Error parsing/)
		end
		it "handles ERB templates properly" do
			expect { kcf.parse_config("#{kcf.config_path}/erbtest.yml") }.not_to raise_error
		end
	end
	describe "#config" do
		context "using the test config" do
			it "yields a config that has usable recipes and attributes sections" do
				kcf.do_parse_configs()
				expect(kcf.config()).to include("recipes","attributes")
			end
			it "deep merges attributes when groups are populated" do
				Etc.stub(:getlogin => "user1" )
				kcf.do_parse_configs()
				expect(kcf.config()).to include("recipes","attributes")
			end
		end
		context "using two group configs" do
			let(:group_configs) do
				{
					"group1" => {
					"recipes" => { "global" => ["a::default"] },
					"attributes" => { "foo" => "bar" },
					},
					"group2" => {
					"recipes" => { "example" => ["b::default"] },
					"attributes" => { "bar" => "baz" }
					}

				}
			end
			it "merges in a platform-specific recipe" do
				kcf.do_parse_configs()
				puts "kcf: #{kcf.ohai['platform_family']}"
				kcf.instance_variable_set(:@group_configs,group_configs)
				expect(kcf.config()["recipes"]).to include("b::default")
			end
		end
	end
end
