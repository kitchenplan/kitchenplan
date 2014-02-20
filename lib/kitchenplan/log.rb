require 'logger'
require 'mixlib/log'

class Kitchenplan
  # our general-purpose logger.  this is similar to how Chef logs, but much simpler.
  # TODO: should probably add the capability to write to a logfile plus runtime configuration.
  class Log
    extend Mixlib::Log

    init(Logger.new(STDOUT))

    # set up our default formatter.
    class Formatter
      # pass #show_time= arguments back up to Mixlib::Log::Formatter
      def self.show_time=(*args)
	Mixlib::Log::Formatter.show_time = *args
      end
    end
  end
end
