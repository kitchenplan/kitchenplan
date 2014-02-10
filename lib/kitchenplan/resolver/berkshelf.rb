class Kitchenplan
  class Resolver
    class Berkshelf < Kitchenplan::Resolver
      # load up whatever information is necessary to use this dependency resolver.
      def initialize()
	# debug is just an internal flag we use to track whether we should use debug output,
	# it gets passed from optparse.
	super
	raise "Berkshelf not installed" unless present?
      end
      def name
	"Berkshelf"
      end
      # is this dependency resolver present?  should we use it?
      def present?
	File.exist?("Berksfile") and `berks`
      end
      def debug?
	@debug
      end
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
