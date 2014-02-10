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
    attr_accessor :resolver
    def initialize
	detect_platform()
	detect_resolver()
    end
    def detect_platform
	self.platform = eval("Kitchenplan::Platform::#{Kitchenplan::Platform.constants.first.to_s}.new()") unless defined?(self.platform) and self.platform.nil? == false
    end

    def detect_resolver
	if defined?(self.resolver) and self.resolver.nil? == false
	    return self.resolver
	end
	Kitchenplan::Log.debug "self.resolver == #{self.resolver.class}"
	# look for all resolvers in our lib directory and attempt to include them.
	begin
	    Dir.glob(File.expand_path("../kitchenplan/resolver/*.rb", __FILE__)).each do |file|
		Kitchenplan::Log.debug "Loading #{file}"
		require file
	    end
	rescue Exception => e
	    Kitchenplan::Log.error "Ack!  #{e.message}"
	end
	# loop through the resolver classes we just loaded and see which (if any) will load up for us.
	# this should catch plugins, too, if you cleverly load them somehow.
	Kitchenplan::Resolver.constants.each do |resolver_candidate|
	    Kitchenplan::Log.info "resolver candidate: #{resolver_candidate.to_s}"
	    begin
		self.resolver = eval("Kitchenplan::Resolver::#{resolver_candidate.to_s}.new()") unless self.resolver.nil? == false
		Kitchenplan::Log.debug "self.resolver == #{self.resolver.class}"
		break
	    rescue Exception => e
		Kitchenplan::Log.debug "Resolver instantiation error: #{e.message} #{e.backtrace}"
	    end
	end
	if self.resolver.nil?
	    Kitchenplan::Log.warn "No resolvers loaded.  This could be a problem."
	end
    end

    # class method for executing a command as superuser.
    def sudo *args
	detect_platform
	Kitchenplan::Log.info self.platform.run_privileged(*args)
	system self.platform.run_privileged(*args)
    end
    # class method for executing a regular command.
    def normaldo *args
	detect_platform
	Kitchenplan::Log.info *args
	system *args
    end
end
