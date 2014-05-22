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

require 'kitchenplan/application'

class Kitchenplan
  class Platform
    # linux support is provided by this class.  honestly this is here as a bit of a best guess
    # and it needs to be tested.
    # TODO: Test generic Linux support and update this class as needed.
    class Linux < Kitchenplan::Platform
      # instantiate class with a name and version.
      def initialize(ohai)
	@lowest_version_supported = "00"
	self.ohai = ohai
	self.name = self.ohai["platform_family"]
	self.version = self.ohai["platform_version"]
	self.omnibus_path = "/opt/chef"
	Kitchenplan::Log.debug "#{self.class} : Platform name: #{self.name}  Version: #{self.version}"
      end
      # are we running as superuser?  (we shouldn't be.  we'll sudo/elevate as needed.)
      def running_as_normaluser?
	Kitchenplan::Log.debug "#{self.class} : Running as normal user? UID = #{Process.uid} != 0?"
	Process.uid != 0
      end
      # is this version of the platform supported by the kitchenplan codebase?
      def version_supported?
	Kitchenplan::Log.debug "#{self.class} : Is platform version lower than #{@lowest_version_supported}?"
	return false if self.version.to_s <  @lowest_version_supported
	true
      end
      # test to see if the Bundler gem is installed via this platform.
      def bundler_installed?
	`(gem spec bundler -v > /dev/null 2>&1)`
      end
      # install bundler on this platform via gem.
      def install_bundler
	# What we really need to do is check the result of the normaldo and then do a wrapped sudo.
	# That should be good on different platforms as long as Ruby's present.
	sudo "gem install bundler --no-rdoc --no-ri" unless bundler_installed?
      end
      # test if git command works on this platform.
      def git_installed?
	`git config > /dev/null 2>&1`
      end
      # install git if it isn't installed already.
      def install_git
	Kitchenplan::Log.error "Install_Git not implemented on this platform"
      end
      # test to see if the current user is part of the admin group.
      def user_is_admin?
	`groups`.split.include? "admin"
      end
      # TODO: Move up to base
      def prerequisites
	Kitchenplan::Application.fatal! "Don't run this as root!" unless running_as_normaluser?
	Kitchenplan::Application.fatal! "#{ENV['USER']} needs to be part of the 'admin' group!" unless user_is_admin?
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
	sudo "bundle install --binstubs=bin --quiet"
      end
    end
  end
end
