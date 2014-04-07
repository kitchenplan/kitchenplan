require 'spec_helper'
require 'kitchenplan'

describe Kitchenplan::Platform do
	platforms = {
		'mac_os_x' => ['10.8.2','10.7.4'],
		'redhat' => ['6.3','5.8'],
		'ubuntu' => ['12.04']
	}
	platforms.each do |platform, versions|
		versions.each do |version|
			context "On #{platform} #{version}" do
				before do
					Fauxhai.mock(platform:platform, version: version)
				end
				let(:config) { Kitchenplan::Config.new(parse_configs=false,ohai=Fauxhai.mock(platform:platform, version:version).data)}
				it 'should load the Kitchenplan platform corresponding to the Ohai platform' do
					puts config.inspect
					config.platform.name.should eq(platform)
					# version is detected through non-ohai means.
					# is that a feature?
					# config.platform.version.should eq(version)
				end
			end
		end
	end
	describe 'sudo' do
		# foo
	end
end
