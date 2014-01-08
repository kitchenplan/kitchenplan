require 'json'
require 'kitchenplan/mixins'
require 'kitchenplan/log'
require 'kitchenplan/config'
# platform-specificity
require 'kitchenplan/platform'
begin
require "kitchenplan/platform/#{Kitchenplan::Config.new(parse_configs=false).platform}"
rescue LoadError
	raise "Unsupported platform or fatal error loading support for platform '#{Kitchenplan::Config.new(parse_configs=false).platform}' ..."
end
class Kitchenplan
	attr_accessor :platform
	def initialize
		self.platform = eval("Kitchenplan::Platform::#{Kitchenplan::Platform.constants.first.to_s}.new()")
	end
end
