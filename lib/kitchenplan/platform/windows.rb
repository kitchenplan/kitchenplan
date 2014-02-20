class Kitchenplan
  class Platform
    # Support for the Windows platform family.  Currently we do not distinguish between versions.
    # Omnibus Chef is only fully supported on Windows 2008 or newer.
    class Windows < Kitchenplan::Platform
      # set up some basic info about the platform.
      def initialize
	@lowest_version_supported = "00"
	self.name = "windows"
	self.version = "generic"
	Kitchenplan::Log.debug "#{self.class} : Platform name: #{self.name}  Version: #{self.version}"
      end
      # are we running as superuser?  (we shouldn't be.  we'll sudo/elevate as needed.)
      def running_as_superuser?
	Kitchenplan::Log.debug "#{self.class} : Running as superuser? UID = #{Process.uid} == 0?"
	Process.uid == 0
      end
      # is this version of the platform supported by the kitchenplan codebase?
      def version_supported?
	Kitchenplan::Log.debug "#{self.class} : Is platform version lower than #{@lowest_version_supported}?"
	return false if self.version.to_s <  @lowest_version_supported
	true
      end
      # test to see if the bundler gem is installed.
      # TODO: Possible false negative if gem is not in path.  also ... /dev/null?  does this work?
      def bundler_installed?
	`(gem spec bundler -v > /dev/null 2>&1)`
      end
      # install Bundler using the omnibus version of Rubygems
      def install_bundler
	# What we really need to do is check the result of the normaldo and then do a wrapped sudo.
	# That should be good on different platforms as long as Ruby's present.
	sudo "C:/opscode/chef/embedded/bin/gem install bundler --no-rdoc --no-ri" unless bundler_installed?
      end
      # test to see if git is installed on this platform.
      def git_installed?
	`git config > /dev/null 2>&1`
      end
      # install git on this platform.  (not actually used here.)
      def install_git
	Kitchenplan::Log.debug "Git is installed by the go.bat bootstrap on Windows, skipping install_git()"
      end
      # can the current user run elevated commands?
      def user_is_admin?
	`gpresult /r /scope user`.split.include? "Admin"
      end
      # TODO: Move up to base
      def prerequisites
	Kitchenplan::Application.fatal! "Don't run this as root!" if running_as_superuser?
	Kitchenplan::Application.fatal! "#{ENV['USER']} needs to be part of the 'admin' group!" if user_is_admin?
	Kitchenplan::Application.fatal! "Platform version too low.  Your version: #{self.version}" unless version_supported?
	install_bundler
	# needed for proper librarian usage
	install_git
	kitchenplan_bundle_install
      end
      # elevates and runs bundle install for kitchenplan.
      # TODO: move up into base
      def kitchenplan_bundle_install
	Kitchenplan::Log.info "#{self.class} : Run kitchenplan bundle install"
	sudo "C:\\opscode\\chef\\embedded\\bin\\bundle.bat install --binstubs=bin --quiet"
      end
    # the function in which Chef is actually executed.  This should be platform-independent,
    # though we will care about whether we run via chef-solo or chef-zero.
    # Boolean use_solo determines whether or not chef-solo or chef-zero (Chef 11.8 or newer) is used.
    def run_chef(use_solo=true, log_level='info', recipes=[])
      chef_bin = use_solo ? "chef-solo" : "chef-client -z"
      sudo "C:\\opscode\\chef\\embedded\\bin\\#{chef_bin}.bat --log_level #{log_level} -c solo.rb -j kitchenplan-attributes.json -o #{recipes.join(",")}"
    end
    # run a command as a privileged user (i.e., Administrator)
    # We hard-code the name of the Administrator account here, so if your administrator account has been renamed, you're going to have a bad time.
    def run_privileged *args
      args = if args.length > 1
	       args.unshift "start /b runas /savecred /env /user:Administrator \""
	       args << '"'
	     else
	       "start /b runas /savecred /env /user:Administrator \"#{args.first}\""
	     end
    end
      private
      def sudo *args
	Kitchenplan::Application.new().sudo(*args)
      end
    end
  end
end
