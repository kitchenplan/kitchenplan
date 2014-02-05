class Kitchenplan
  class LibrarianChefResolver < Kitchenplan::Resolver
    # load up whatever information is necessary to use this dependency resolver.
    def initialize(debug=false)
      # debug is just an internal flag we use to track whether we should use debug output,
      # it gets passed from optparse.
      @debug = debug
      raise "Librarian not installed" unless present?
    end
    # is this dependency resolver present?  should we use it?
    def present?
      Kitchenplan::Log.warn "No prerequisites defined for platform '#{@platform}'"
    end
    # actually run the resolver and download the cookbooks we need.
    def fetch_dependencies()
      self.normaldo "bin/librarian-chef install --clean #{(@debug ? '--verbose' : '--quiet')}"
    end
    # update dependencies after the initial install
    def update_dependencies()
      self.normaldo "bin/librarian-chef update --clean #{(@debug ? '--verbose' : '--quiet')}"
    end

  end
end
