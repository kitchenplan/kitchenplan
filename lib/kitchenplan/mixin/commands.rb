class Kitchenplan
  module Mixin
    # mixin commands!  we use these in multiple places so this seems to make sense.
    # after adding them to the root class, though, this may not make sense anymore.
    # TODO: Figure out if the entire Kitchenplan::Mixin::Commands module can go.
    module Commands
      # run a sudo command and log the results.
      def sudo *args
	Kitchenplan::Log.info self.platform.run_privileged(*args)
	system self.platform.run_privileged(*args)
      end

      # run a normal command and log the results.
      def normaldo *args
	Kitchenplan::Log.info *args
	system *args
      end
    end
  end
end
