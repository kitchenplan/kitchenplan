require 'spec_helper'
require 'ohai'
require 'kitchenplan'

describe Kitchenplan do
	describe "detect_platform" do
		let(:system_ohai) { Ohai::System.new() }
		it "uses system ohai if the passed ohai param is nil" do
			system_ohai.require_plugin("os")
			system_ohai.require_plugin("platform")
			kp = Kitchenplan.new(ohai=nil)
			kp.detect_platform(ohai=nil)
			expect(kp.platform.ohai).to match system_ohai
		end
	end
		
end
