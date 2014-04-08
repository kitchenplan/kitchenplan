require 'kitchenplan/platform/linux'
class Kitchenplan
  class Platform
    # Hopefully we can support flavors of Linux by subclassing the generic Linux platform.
    # This class is here as a sort of proof-of-concept, since I haven't actually tried running
    # kitchenplan on Debian-family yet.  Let me know how it goes!  -sw
    class Debian < Kitchenplan::Platform::Linux
      # Set up information about this particular platform.
      def initialize(ohai)
	@lowest_version_supported = "12.04"
	self.ohai = ohai.nil? ? Ohai::System.new : ohai
	self.name = self.ohai["platform_family"]
	self.version = self.ohai["platform_version"]
	Kitchenplan::Log.debug "#{self.class} : Platform name: #{self.name}  Version: #{self.version}"
      end
      # installing git is done with apt on Debian.
      def install_git
	sudo "apt-get install git" unless git_installed?
      end
      # prerequisites should be the same, but if they aren't, we can do Debian-specific things here.
      # TODO: Move up to base
      def prerequisites
	super
      end
      private
      # Run sudo commands.
      # TODO: This probably doesn't need to be here anymore...
      def sudo *args
	Kitchenplan::Application.new().sudo(*args)
      end
    end
  end
end
