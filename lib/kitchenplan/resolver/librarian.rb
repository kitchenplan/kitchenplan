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
    # support for Librarian as a Chef cookbook dependency resolver.  There must be a Cheffile in the repository
    # for this resolver to work properly, even if you do have librarian-chef installed.
    class Librarian < Kitchenplan::Resolver
      attr_accessor :debug
      attr_accessor :config_dir
      # load up whatever information is necessary to use this dependency resolver.
      def initialize(debug=false)
	super()
	Kitchenplan::Log.debug "Librarian resolver not present" unless present?
      end
      # proper name of the resolver
      def name
	"librarian-chef"
      end
      # is this dependency resolver present?  should we use it?
      def present?
	if @config_dir
	  File.exist?("#{@config_dir}/Cheffile") and system("#{self.binary} > /dev/null 2>&1")
	else
	  File.exist?("Cheffile") and system("#{self.binary} > /dev/null 2>&1")
	end
      end
      # actually run the resolver and download the cookbooks we need.
      def fetch_dependencies()
	"cd #{self.config_dir} ; #{self.binary} install --clean #{(@debug ? '--verbose' : '--quiet')} --path=#{Dir.pwd}/cookbooks"
      end
      # update dependencies after the initial install
      def update_dependencies()
	"cd #{self.config_dir} ; #{self.binary} update --clean #{(@debug ? '--verbose' : '--quiet')} --path=#{Dir.pwd}/cookbooks"
      end
    end
  end
end
