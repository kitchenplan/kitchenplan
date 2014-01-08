module Kitchenplan
  module Mixin
    module Commands
      def sudo *args
	Kitchenplan::Log.info self.platform.run_privileged(*args)
	system self.platform.run_privileged(*args)
      end

      def normaldo *args
	Kitchenplan::Log.info *args
	system *args
      end
    end
  end
end
