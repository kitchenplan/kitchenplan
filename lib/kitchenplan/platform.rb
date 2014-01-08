module Kitchenplan
  class Platform
    # :name is based on the ohai name of the platform.  by convention this is also the class name
    # and file name of the source
    attr_accessor :name
    # :version is usually based on the ohai platform version.
    attr_accessor :version
    # load up whatever information is necessary for the current platform version to determine state
    # (beyond just copying what we get out of ohai, that is)
    def initialize(debug=false)
      # debug is just an internal flag we use to track whether we should use debug output,
      # it gets passed from optparse.
      @debug = debug
      Kitchenplan::Log.warn "There was an error loading support for Kitchenplan on your platform."
    end
    # runs through the platform prerequisites.  generally we want a few things on all platforms, so
    # you won't want to completely override this on your platform.  each component is separated out
    # into a check and an install command - you'll probably want to look there first.
    def prerequisites
      Kitchenplan::Log.warn "No prerequisites defined for platform '#{@platform}'"
    end
    # run_privileged, for when we want to run something as root.  we just format the command syntax here.
    # execution happens elsewhere.
    def run_privileged *args
      args = if args.length > 1
	       args.unshift "/usr/bin/sudo"
	     else
	       "/usr/bin/sudo #{args.first}"
	     end
    end
    # the function in which Chef is actually executed.  This should be platform-independent,
    # though we will care about whether we run via chef-solo or chef-zero.
    # Boolean use_solo determines whether or not chef-solo or chef-zero (Chef 11.8 or newer) is used.
    def run_chef(use_solo=true, log_level='info', recipes=[])
      chef_bin = use_solo ? "chef-solo" : "chef-client -z"
      sudo "bin/#{chef_bin} --log_level #{log_level} -c solo.rb -j kitchenplan-attributes.json -o #{recipes.join(",")}"
    end

  end
end
