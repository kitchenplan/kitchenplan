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

require 'kitchenplan'
require 'kitchenplan/application'
class Kitchenplan
  class Platform
    # OS X support.  This is probably the primary development platform for Kitchenplan today and
    # this code should therefore work real good.
    class MacOsX < Kitchenplan::Platform
      attr_accessor :omnibus_path
      def initialize(ohai)
	# haven't tested on Lion yet, unfortunately.  if you have and this works, let me know. -sw
	@lowest_version_supported = "10.8"
	self.ohai = ohai
	self.name = self.ohai["platform_family"]
	self.version = self.ohai["platform_version"]
	# dangerous assumption:  you're installing Chef to your system.  like, for real.
	self.omnibus_path = "/opt/kitchenplan"
	Kitchenplan::Log.debug "#{self.class} : Platform name: #{self.name}  Version: #{self.version}"
      end
      # are we running as superuser?  (we shouldn't be.  we'll sudo/elevate as needed.)
      def running_as_normaluser?
	Kitchenplan::Log.debug "#{self.class} : Running as superuser? UID = #{Process.uid} != 0?"
	Process.uid != 0
      end
      # is this version of the platform supported by the kitchenplan codebase?
      def version_supported?
	Kitchenplan::Log.debug "#{self.class} : Is platform version lower than #{@lowest_version_supported}?"
	return false if self.version.to_s <  @lowest_version_supported
	true
      end
      # is the user part of the admin group?
      def user_is_admin?
	`groups`.split.include? "admin"
      end
      # test to see if the Bundler gem is installed.
      def bundler_installed?
	`(gem spec bundler -v > /dev/null 2>&1)`
      end
      # install bundler if needed.
      def install_bundler
	# What we really need to do is check the result of the normaldo and then do a wrapped sudo.
	# That should be good on different platforms as long as Ruby's present.
	sudo "gem install bundler --no-rdoc --no-ri" unless bundler_installed?
      end
      # test to see if Git is installed and available.
      def git_installed?
	`git config > /dev/null 2>&1`
      end
      # install git using Homebrew.
      # TODO: Homebrew?  Is that a dependency we're tracking in the go script?  How do we know it's installed?
      def install_git
	sudo "brew install git" unless git_installed?
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
	sudo "bundle install --binstubs=#{self.omnibus_path}/bin --quiet"
      end
    end
  end
end
