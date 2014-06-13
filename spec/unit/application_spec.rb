# Copyright 2014 Disney Enterprises, Inc. All rights reserved
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are
#  met:
#
#   * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.

require 'spec_helper'
require 'ohai'
require 'kitchenplan'
require 'kitchenplan/application'
require 'kitchenplan/resolver/librarian'

describe Kitchenplan::Application do
	before do
		# suppresses all logging.
		Kitchenplan::Log::MultiIO.any_instance.stub(:write => "")
		Kitchenplan::Application.any_instance.stub(:puts => "")
	end
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
			:log_level=>"none", :log_file => nil, :config_dir=>"config/", :chef=>true, :chef_mode => "solo", :fake => true
		}
	end
	let(:kp) { Kitchenplan::Platform.new(ohai=fake_ohai) }
	let(:kr) { Kitchenplan::Resolver.new() }
	let(:kc) do
		kc = Kitchenplan::Config.new(ohai=fake_ohai,parse_configs=false)
		kc.instance_variable_set(:@ohai,fake_ohai)
	end
	let(:kpd) do
		kpd = double("Kitchenplan::Platform", :ohai => fake_ohai) 
		kpd.stub(:name => "example_platform", :version => "example_platform_version", :ohai => fake_ohai)
		kpd.stub(:prerequisites => true, :run_chef => "the power of chef commands thee", :sudo => true, :normaldo => true)
		kpd
	end
	let(:krl) do
		krl = double("Kitchenplan::Resolver::Librarian")
		krl.stub(:name => "Librarian", :fetch_dependencies => true, :update_dependencies => true, :debug => true)
		krl
	end
	let(:kac) do
		kac = Kitchenplan::Application.new(bare=true,argv=[] )
		kac.platform = kpd
		kac.resolver = krl
		kac.stub(:exit! => false, :fatal! => false )
		kac
	end
	let(:ka) do
		ka = double("Kitchenplan::Application", :bare => true, :argv => [])
		ka.stub(:platform => kpd, :resolver= => krl, :options => fake_options)
		ka.stub(:exit! => false, :fatal! => false)
		ka
	end
	describe "#initialize" do
		before do
			#Kitchenplan::Application.any_instance.stub(:parse_commandline => {}, :configure_logging => true, :detect_platform => true, :detect_resolver => true, :load_config => true)
		end
		[ true, false ].each do |bareflag|
			context "when bare parameter is #{bareflag}" do
				let(:ARGV) { [] }
				let(:ka) do
					ka = Kitchenplan::Application.new(bare=bareflag,argv=[] )
					ka.platform = kpd
					ka.resolver = krl
					ka.stub(:exit! => false, :fatal! => false, :load_config => {}, :prepare => false)
					ka
				end
				act = bareflag == true ? "skips" : "calls"
				it "#{act} #prepare" do
					if bareflag == true
						expect(ka).not_to receive :prepare
					else
						pending "prepare() doesn't receive the signal for some reason"
						expect(ka).to receive :prepare
					end
					ka
				end
			end
		end
	end
	describe "#prepare" do
		it "populates self.options with the result of #parse_commandline" do
			kac.stub(:parse_commandline => fake_options)
			kac.stub(:platform => kpd)
			kac.prepare(argv=[])
			expect(kac.options).to include(:fake => true)
		end

		%w{ configure_logging detect_platform detect_resolver load_config }.each do |f|
			it "runs ##{f}()" do
				kac.stub(:platform => kpd)
				kac.stub(:load_config => {}) unless f == "load_config"
				expect(kac).to receive f.to_sym
				kac.prepare([])
			end
		end
	end
	describe "#parse_commandline" do
		let(:ka) { kac }
		before do
			ka.stub( :configure_logging => false, :run => false, :update_cookbooks => false, :detect_resolver => false )
		end
		%w{ -h --help}.each do |flag|
			it "should display a help message when passed #{flag}" do
				argv = [ flag ]
				expect { ka.parse_commandline(argv) }.to raise_error(SystemExit)
			end
		end
		%w{ -c --config-dir }.each do |flag|
			it "should set the config dir to a custom value" do
				argv = [ flag, "/custom_directory" ]
				expect(ka.parse_commandline(argv)).to include( :config_dir => "/custom_directory" )
			end
		end
		%w{ -u --update-cookbooks }.each do |flag|
			it "should set the update_cookbooks flag when passed '#{flag}'" do
				argv = [ flag ]
				expect(ka.parse_commandline(argv)).to include( :update_cookbooks => true )
			end
		end
		%w{ -l --log-level }.each do |flag|
			it "should set the log level argument when passed '#{flag}'" do
				argv = [ flag, "debug" ]
				expect(ka.parse_commandline(argv)).to include( :log_level => "debug" )
			end
		end
		it "should set the log file argument when a parameter is passed" do
			argv = [ "--log-file", "example.txt" ]
			expect(ka.parse_commandline(argv)).to include( :log_file => "example.txt" )
		end
		%w{ a foo::bar foo::default,bar::default }.each do |recipe_str|
			it "should populate recipes with #{recipe_str}" do
				argv = [ "--recipes", recipe_str ]
				expect(ka.parse_commandline(argv)).to include( :recipes => recipe_str.split(",") )
			end
		end
		%w{ --chef --no-chef }.each do |flag|
			res = flag.include?("no-") ? false : true
			it "should set the chef flag to #{res} when passed '#{flag}'" do
				argv = [ flag ]
				expect(ka.parse_commandline(argv)).to include( :chef => res )
			end
		end
		%w{ -v --version }.each do |flag|
			it "should show the current version" do
				argv = [ flag ]
				expect { ka.parse_commandline(argv) }.to raise_error(SystemExit)
			end
		end
	end
	describe "#configure_logging" do
		pending
	end
	describe "#load_config" do
		context "when using the fixture config path" do
			before do
				kac.options = { :config_dir => FIXTURE_CONFIG_DIR }
				kac.load_config()
			end

			it "should return a config hash that has an 'attributes' key" do
				kac.config.instance_variable_set(:@ohai,fake_ohai)
				expect(kac.config).not_to eq nil
				expect(kac.config).to include("attributes")
			end
			it "should return a config hash that has a 'recipes' key" do
				kac.config.instance_variable_set(:@ohai,fake_ohai)
				expect(kac.config).to include("recipes")
			end
		end
	end
	describe "#generate_chef_config" do
		let(:cfg) { { 'attributes' => { "a" => "b", "c" => ["d","e","f"] } } }
		before do
			File.delete("kitchenplan-attributes.json") if File.exists?("kitchenplan-attributes.json")
		end
		it "writes a parseable file" do
			kac.stub(:config => cfg)
			kac.generate_chef_config()
			expect( JSON.parse( IO.read("kitchenplan-attributes.json") ) ).to include("a" => "b")
		end
		after do
			File.delete("kitchenplan-attributes.json") if File.exists?("kitchenplan-attributes.json")
		end

	end
	describe "#update_cookbooks" do
		before do
			kac.options = { :debug => true }
			kac.resolver.stub(:debug= => true )
		end
		it "should set self.resolver.debug to the options debug value" do
			kac.update_cookbooks()
			expect(kac.resolver.debug).to be_true
		end
		context "when 'cookbooks' exists" do
			before { File.new("cookbooks","w") }
			it "should not fetch a fresh set of cookbooks" do
				expect(kac.resolver).not_to receive :fetch_dependencies
				kac.update_cookbooks
			end
			after { File.delete("cookbooks") }
		end
		context "when 'cookbooks' does not exist" do
			before do
				File.delete("cookbooks") if File.exists?("cookbooks")
			end
			it "should fetch a fresh set of cookbooks" do
				expect(kac.resolver).to receive :fetch_dependencies
				kac.update_cookbooks
			end
		end
		context "when update_cookbooks is set" do
			before do
				kac.options = { :debug => false, :update_cookbooks => true }
			end
			it "should tell the resolver to update cookbooks with resolver#update_dependencies" do
				expect(kac.resolver).to receive :update_dependencies
				kac.update_cookbooks
			end
		end
	end
	describe "#ping_google_analytics" do
		before do
			Gabba::Gabba.any_instance.stub(:event => "got it")
		end
		it "should send an event through Gabba" do
			expect(kac.ping_google_analytics()).to eq "got it"
		end
	end
	describe "#run" do
		before do
			kac.stub(:parse_options => fake_options,
				 :detect_resolver => Kitchenplan::Resolver::Librarian.new(debug=true),
				 :configure_logging => true,
				 :load_config => true,
				 :generate_chef_config => true,
				 :ping_google_analytics => true,
				 :update_cookbooks => true,
				 :exit! => true,
				 :options => fake_options,
				 :config => { 'recipes' => ["a::default"], 'attributes' => {"b" => "c"} }
				)
			Gabba::Gabba.any_instance.stub(:event => "got it")
		end
		it "calls the platform object to ensure prerequisites are installed" do
			kac.run()
			expect(ka.platform).to have_received :prerequisites
		end
		it "generates the Chef attribute JSON and run list" do
			kac.run()
			expect(kac).to have_received :generate_chef_config
		end
		it "pings google analytics" do
			kac.run()
			expect(kac).to have_received :ping_google_analytics
		end
		it "tells the resolver to update cookbooks" do
			kac.run()
			expect(kac).to have_received :update_cookbooks
		end
		it "runs chef as superuser via platform object" do
			pending "Not implemented yet."
		end
	end
	%w{fatal exit}.each do |f|
		describe "##{f}!" do
			pending
		end
	end
end
