require 'spec_helper'
require 'kitchenplan'

describe Kitchenplan::Platform do
	platforms = {
		'mac_os_x' => ['10.8.2','10.7.4'],
		'redhat' => ['6.3','5.8'],
		'ubuntu' => ['12.04'],
		'windows' => ['2008R2']

	}
	platforms.each do |platform, versions|
		versions.each do |version|
			context "On #{platform} #{version}" do
				let(:config) { Kitchenplan::Config.new(parse_configs=false,ohai=Fauxhai.mock(platform:platform, version:version).data)}
				it 'should load the corresponding Kitchenplan platform class' do
					case platform
					when /redhat|amazon|centos|xenserver|oracle/
						my_platform = "rhel"
					when /debian|ubuntu/
						my_platform = "debian"
					else
						my_platform = platform
					end
					config.platform.name.should eq(my_platform)
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
