class Kitchenplan
  class Platform
    class Debian < Kitchenplan::Platform::Linux
      def initialize
	@lowest_version_supported = "12.04"
	self.name = "debian"
	self.version = `/usr/bin/sw_vers -productVersion`.chomp[/10\.\d+/]
	Kitchenplan::Log.info "#{self.class} : Platform name: #{self.name}  Version: #{self.version}" if @debug
      end
      # are we running as superuser?  (we shouldn't be.  we'll sudo/elevate as needed.)
      def install_git
	sudo "apt-get install git" unless git_installed?
      end
      # TODO: Move up to base
      def prerequisites
	super
      end
      private
      def sudo *args
	Kitchenplan::Application.new().sudo(*args)
      end
    end
  end
end
