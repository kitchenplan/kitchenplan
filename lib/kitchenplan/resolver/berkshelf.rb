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

require 'kitchenplan/resolver'
class Kitchenplan
  class Resolver
    # This class contains support for the Berkshelf resolver (berkshelf.com).
    # Kitchenplan has historically used librarian-chef, but Berkshelf is gaining
    # popularity in the Chef community so here it is.
    # This resolver will fail if there is no Berksfile in the repository root or
    # if the `berks` command is not in the path.
    class Berkshelf < Kitchenplan::Resolver
      # should commands be run with debug output?
      attr_accessor :debug
      # the config directory is assumed to contain a dependency file (Berksfile/Cheffile).
      attr_accessor :config_dir
      # load up whatever information is necessary to use this dependency resolver.
      def initialize(debug=false)
	super
      end
      # return the name of this resolver.
      def name
	"berks"
      end
      # is this dependency resolver present?  should we use it?
      def present?
	if @config_dir
	  Kitchenplan::Log.debug("Config dir has Berksfile? #{File.exist?("#{@config_dir}/Berksfile")}")
	  Kitchenplan::Log.debug("#{self.binary} exists? #{File.exist?("#{self.binary}")}")
	  Kitchenplan::Log.debug `which berks`
	  File.exist?("#{@config_dir}/Berksfile") and system("#{self.binary} > /dev/null 2>&1")
	else
	  Kitchenplan::Log.debug("Current directory has Berksfile? #{File.exist?("Berksfile")}")
	  Kitchenplan::Log.debug("#{self.binary} exists? #{File.exist?("#{self.binary}")}")
	  File.exist?("Berksfile") and system("#{self.binary} > /dev/null 2>&1")
	end
      end
      # actually run the resolver and download the cookbooks we need.
      def fetch_dependencies()
	"cd #{self.config_dir} ; #{self.binary} vendor #{(@debug ? '-d' : '-q')} #{Dir.pwd}/cookbooks"
      end
      # update dependencies after the initial install
      def update_dependencies()
	"cd #{self.config_dir} ; #{self.binary} vendor #{(@debug ? '-d' : '-q')} #{Dir.pwd}/cookbooks"
      end
    end
  end
end
