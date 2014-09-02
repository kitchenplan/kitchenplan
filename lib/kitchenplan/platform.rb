# Copyright 2014 Disney Enterprises, Inc. All rights reserved
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are
#  met:
#
#   * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.

class Kitchenplan
  # abstract platform class.
  class Platform
    # :name is based on the ohai name of the platform.  by convention this is also the class name
    # and file name of the source
    attr_accessor :name
    # :version is usually based on the ohai platform version.
    attr_accessor :version
    # :ohai is a copy of the ohai data loaded by the platform detector, in case we need it for
    # further operations.
    attr_accessor :ohai
    # path on local filesystem to omnibus directory (default: /opt/chef)
    attr_accessor :omnibus_path
    # load up whatever information is necessary for the current platform version to determine state
    # (beyond just copying what we get out of ohai, that is)
    def initialize(ohai, debug=false)
      # debug is just an internal flag we use to track whether we should use debug output,
      # it gets passed from optparse.
      @debug = debug
      @ohai = ohai
      @lowest_version_supported = 0
      self.name = ohai["platform_family"]
      self.version = ohai["platform_version"]
      self.omnibus_path = "/opt/chef"
      Kitchenplan::Log.warn "There was an error loading support for Kitchenplan on your platform (#{self.name} #{self.version})."
    end
    # runs through the platform prerequisites.  generally we want a few things on all platforms, so
    # you won't want to completely override this on your platform.  each component is separated out
    # into a check and an install command - you'll probably want to look there first.
    def prerequisites
      Kitchenplan::Log.warn "No prerequisites defined for platform '#{@platform}'"
    end
    def version_supported?
      Kitchenplan::Log.debug "#{self.class} : Is platform version lower than #{@lowest_version_supported}?"
      return false if self.version.to_s <  @lowest_version_supported
      true
    end
    # shouldn't run kitchenplan as superuser.  we can elevate where needed.
    def running_as_normaluser?
      Kitchenplan::Log.debug "#{self.class} : Running as normal user? UID = #{Process.uid} != 0?"
      Process.uid != 0
    end
    # run_privileged, for when we want to run something as root.  we just format the command syntax here.
    # execution happens elsewhere.
    def run_privileged *args
      args = if args.length > 1
	       args.first == "/usr/bin/sudo" ? args : args.unshift("/usr/bin/sudo")
	     else
	       "/usr/bin/sudo #{args.first}"
	     end
    end
    # the function in which Chef is actually executed.  This should be platform-independent,
    # though we will care about whether we run via chef-solo or chef-zero.
    # Boolean use_solo determines whether or not chef-solo or chef-zero (Chef 11.8 or newer) is used.
    def run_chef(use_solo=true, log_level='info', log_file=nil, recipes=[])
      chef_bin = use_solo ? "chef-solo" : "chef-client -z"
      log_location = log_file.nil? ? "" : "-L #{log_file}"
      "#{self.omnibus_path}/bin/#{chef_bin} --log_level #{log_level} -c solo.rb -j kitchenplan-attributes.json -o #{recipes.join(",")} #{log_location}"
    end
    # run commands as sudo.  the name is legacy (and short, so we like it), but privilege escalation may involve
    # a different command on your platform.
    def sudo *args
      Kitchenplan::Log.info run_privileged(*args)
      raise RuntimeError,"'#{run_privileged(*args)}' returned non-zero" unless system(run_privileged(*args))
    end
    # class method for executing a regular command. implementation may be platform-specific, so it's defined here. 
    def normaldo *args
      Kitchenplan::Log.info(*args)
      raise RuntimeError,"'#{args}' returned non-zero" unless system(*args)
    end

  end
end
