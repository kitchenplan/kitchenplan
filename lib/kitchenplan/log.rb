# Copyright 2014 Disney Enterprises, Inc. All rights reserved
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are
#  met:
#
#   * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.

require 'logger'
require 'mixlib/log'

class Kitchenplan
  # our general-purpose logger.  this is similar to how Chef logs, but much simpler.
  # TODO: should probably add the capability to write to a logfile plus runtime configuration.
  class Log
    # for logging to multiple places at once.  Minimum implementation required by Logger.
    # Wish I could take credit for this but it's got to go to Stackoverflow:
    # http://stackoverflow.com/a/6407200
    class MultiIO
      # set up logging targets
      def initialize(*targets)
	@targets = targets
      end
      # write message to all targets
      def write(*args)
	@targets.each {|t| t.write(*args)}
      end
      # send #close to all logging targets
      def close
	@targets.each(&:close)
      end
    end

    extend Mixlib::Log

    # set up our default formatter.
    class Formatter
      # pass #show_time= arguments back up to Mixlib::Log::Formatter
      def self.show_time=(*args)
	Mixlib::Log::Formatter.show_time = *args
      end
    end
  end
end
