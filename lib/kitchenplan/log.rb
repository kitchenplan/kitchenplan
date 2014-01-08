require 'logger'
require 'mixlib/log'

class Kitchenplan
  class Log
    extend Mixlib::Log

    init(Logger.new(STDOUT))

    class Formatter
      def self.show_time=(*args)
	Mixlib::Log::Formatter.show_time = *args
      end
    end
  end
end
