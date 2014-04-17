require 'spec_helper'
require 'kitchenplan'
require 'kitchenplan/platform/mac_os_x'

describe Kitchenplan::Platform::MacOsX do
	it_behaves_like "a Kitchenplan platform"
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
	let(:kp) do
		kp = Kitchenplan::Platform::MacOsX.new(ohai=fake_ohai)
		kp.stub(:sudo => true, :normaldo => true)
		kp
	end
	describe "#prerequisites" do
		it "should call #install_bundler" do
			expect(kp).to receive :install_bundler
			kp.prerequisites()
		end
		it "should call #install_git" do
			expect(kp).to receive :install_git
			kp.prerequisites()
		end
		it "should call #kitchenplan_bundle_install" do
			expect(kp).to receive :kitchenplan_bundle_install
			kp.prerequisites()
		end
	end
	describe "#kitchenplan_bundle_install" do
		it "runs sudo with the 'bundle install' command" do
			expect(kp).to receive(:sudo).with(/bundle install/)
			kp.kitchenplan_bundle_install()
		end
	end
	describe "#git_installed?" do
		pending "how do you best test backticks?"
	end
end
