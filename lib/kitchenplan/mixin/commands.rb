module Kitchenplan
  module Mixin
    module Commands
      def sudo *args
	ohai platform.sudo(*args)
	system platform.sudo(*args)
      end

      def normaldo *args
	ohai *args
	system *args
      end
    end
  end
end
