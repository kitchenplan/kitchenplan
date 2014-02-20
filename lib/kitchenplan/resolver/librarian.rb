class Kitchenplan
  class Resolver
    # support for Librarian as a Chef cookbook dependency resolver.  There must be a Cheffile in the repository
    # for this resolver to work properly, even if you do have librarian-chef installed.
    class Librarian < Kitchenplan::Resolver
      # load up whatever information is necessary to use this dependency resolver.
      def initialize()
	# debug is just an internal flag we use to track whether we should use debug output,
	# it gets passed from optparse.
	super
	raise "Librarian not installed" unless present?
      end
      # proper name of the resolver
      def name
	"librarian-chef"
      end
      # is this dependency resolver present?  should we use it?
      def present?
	File.exist?("Cheffile") and `librarian-chef`
      end
      # return the true/false value of @debug
      def debug?
	@debug
      end
      # set @debug to passed value
      def debug=(truthy=false)
	@debug=truthy
      end
      # actually run the resolver and download the cookbooks we need.
      def fetch_dependencies()
	"bin/librarian-chef install --clean #{(@debug ? '--verbose' : '--quiet')}"
      end
      # update dependencies after the initial install
      def update_dependencies()
	"bin/librarian-chef update --clean #{(@debug ? '--verbose' : '--quiet')}"
      end
    end
  end
end
