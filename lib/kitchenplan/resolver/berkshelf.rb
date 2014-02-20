class Kitchenplan
  class Resolver
    # This class contains support for the Berkshelf resolver (berkshelf.com).
    # Kitchenplan has historically used librarian-chef, but Berkshelf is gaining
    # popularity in the Chef community so here it is.
    # This resolver will fail if there is no Berksfile in the repository root or
    # if the `berks` command is not in the path.
    class Berkshelf < Kitchenplan::Resolver
      # load up whatever information is necessary to use this dependency resolver.
      def initialize()
	# debug is just an internal flag we use to track whether we should use debug output,
	# it gets passed from optparse.
	super
	raise "Berkshelf not installed" unless present?
      end
      # return the name of this resolver.
      def name
	"Berkshelf"
      end
      # is this dependency resolver present?  should we use it?
      def present?
	File.exist?("Berksfile") and `berks`
      end
      # return value of @debug
      def debug?
	@debug
      end
      # set debug to a true/false value.
      def debug=(truthy=false)
	@debug=truthy
      end
      # actually run the resolver and download the cookbooks we need.
      def fetch_dependencies()
	"berks install --path cookbooks #{(@debug ? '-v' : '-q')}"
      end
      # update dependencies after the initial install
      def update_dependencies()
	"berks update --path cookbooks #{(@debug ? '-d' : '-q')}"
      end
    end
  end
end
