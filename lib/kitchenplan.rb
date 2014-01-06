require 'kitchenplan/mixins'
require 'kitchenplan/config'
# platform-specificity
require 'kitchenplan/platform'
begin
require "kitchenplan/platform/#{Kitchenplan::Config.new().platform}"
rescue LoadError
	raise "Unsupported platform or fatal error loading support for platform '#{Kitchenplan::Config.new().platform}' ..."
end
class Kitchenplan
	attr_accessor :platform
	def initialize
		self.platform = eval("Kitchenplan::Platform::#{Kitchenplan::Platform.constants.first.to_s}.new()")
	end
end
