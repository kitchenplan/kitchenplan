class Kitchenplan
  class Resolver < Platform
    include Kitchenplan::Mixin::Commands
    # load up whatever information is necessary to use this dependency resolver.
    def initialize()
      # debug is just an internal flag we use to track whether we should use debug output,
      # it gets passed from optparse.
      @debug = debug
      Kitchenplan::Log.warn "There was an error loading a dependency solver, which tells Kitchenplan where to find cookbooks."
    end
    def name
      "undefined"
    end
    # is this dependency resolver present?  should we use it?
    def present?
      Kitchenplan::Log.warn "No detection method defined for resolver."
    end
    # actually run the resolver and download the cookbooks we need.
    def fetch_dependencies()
      Kitchenplan::Log.warn "Kitchenplan can't fetch cookbooks because no dependency solver has been loaded.  This run won't be very useful."
    end

    def resolve_dependencies()

      Kitchenplan::Log.warn "Kitchenplan can't resolve cookbook dependencies because no dependency solver has been loaded.  This run won't be very useful."
    end
  end
end
