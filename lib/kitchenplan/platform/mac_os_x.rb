module Kitchenplan
  class Platform
    class MacOSX < Kitchenplan::Platform
#      include Kitchenplan::Mixin::Commands
      def initialize(debug=false)
	@debug = debug
	@lowest_version_supported = "10.8"
	self.name = "mac_os_x"
	self.version = `/usr/bin/sw_vers -productVersion`.chomp[/10\.\d+/]
	ohai "#{self.class} : Platform name: #{self.name}  Version: #{self.version}" if @debug
      end
      # are we running as superuser?  (we shouldn't be.  we'll sudo/elevate as needed.)
      def running_as_superuser?
	ohai "#{self.class} : Running as superuser? UID = #{Process.uid} == 0?" if @debug
	Process.uid == 0
      end
      # is this version of the platform supported by the kitchenplan codebase?
      def version_supported?
	ohai "#{self.class} : Is platform version lower than #{@lowest_version_supported}?" if @debug
	return false if self.version.to_s <  @lowest_version_supported
	true
      end
      def bundler_installed?
	`(gem spec bundler -v > /dev/null 2>&1)`
      end
      def install_bundler
	# What we really need to do is check the result of the normaldo and then do a wrapped sudo.
	# That should be good on different platforms as long as Ruby's present.
	sudo "gem install bundler --no-rdoc --no-ri" unless bundler_installed?
      end
      def git_installed?
	`git config > /dev/null 2>&1`
      end
      def install_git
	sudo "brew install git" unless git_installed?
      end
      # TODO: Move up to base
      def prerequisites
	abort "Don't run this as root!" if running_as_superuser?
	abort "Platform version too low.  Your version: #{self.version}" unless version_supported?
	install_bundler
	# needed for proper librarian usage
	install_git
	kitchenplan_bundle_install
      end
      # elevates and runs bundle install for kitchenplan.
      # TODO: move up into base
      def kitchenplan_bundle_install
	ohai "#{self.class} : Run kitchenplan bundle install" if @debug
	sudo "bundle install --binstubs=bin #{(@debug ? '--verbose' : '--quiet')}"
      end
    end
  end
end
