require 'ohai'

module Kitchenplan
  class Platform
    attr_accessor :platform
    def detect
	ohai = Ohai::System.new
	ohai.require_plugin("os")
	ohai.require_plugin("platform")
	@platform = ohai[:platform_family]
    end
    def prerequisites
	alert "No prerequisites defined for platform '#{@platform}'"
    end
  end
end
