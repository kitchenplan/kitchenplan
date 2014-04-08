require 'kitchenplan/platform/linux'
class Kitchenplan
  class Platform
    # Hopefully we can support flavors of Linux by subclassing the generic Linux platform.
    # This class is here as a sort of proof-of-concept, since I haven't actually tried running
    # kitchenplan on Debian yet.  Let me know how it goes!  -sw
    class Rhel < Kitchenplan::Platform::Linux
      # Set up information about this particular platform.
      def initialize(ohai=nil)
	@lowest_version_supported = "5.8"
	self.ohai = ohai.nil? ? Ohai::System.new : ohai
	self.name = self.ohai["platform_family"]
	self.version = self.ohai["platform_version"]
	Kitchenplan::Log.debug "#{self.class} : Platform name: #{self.name}  Version: #{self.version}"
      end
      # installing git is done with apt on Debian.
      def install_git
	sudo "yum install git -y" unless git_installed?
      end
      # prerequisites should be the same, but if they aren't, we can do RHEL-specific things here.
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
