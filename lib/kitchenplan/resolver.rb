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

  # abstract resolver.  which subclasses platform because i don't remember why.
  # TODO: remember why resolver subclasses platform.
  class Resolver < Platform
    # debug flag - if we're being run at a high enough debug level to make it worth
    # running our resolver(s) in verbose mode and logging it.
    attr_accessor :debug
    # load up whatever information is necessary to use this dependency resolver.
    def initialize(debug=false)
      @debug = debug
    end
    def name
      "undefined"
    end
    # is this dependency resolver present?  should we use it?
    def present?
      Kitchenplan::Log.warn "No detection method defined for resolver #{self.name}."
    end
    # actually run the resolver and download the cookbooks we need, updating them where necessary.
    def update_dependencies()
      Kitchenplan::Log.warn "Kitchenplan can't fetch cookbooks because no dependency solver has been loaded.  This run won't be very useful."
    end

    # run resolver, determine dependencies and download the cookbooks we need if they don't already exist.
    def fetch_dependencies()
      Kitchenplan::Log.warn "Kitchenplan can't resolve cookbook dependencies because no dependency solver has been loaded.  This run won't be very useful."
    end
  end
end
