require 'optparse'
module Kitchenplan
  module Mixin
    module Optparse
      def parse_commandline
	options = {}
	OptionParser.new do |opts|
	  opts.banner = 'Usage: kitchenplan [options]'
	  opts.on("-d", "--debug", "Show debug information") do |debug|
	    options[:debug] = debug
	  end
	  opts.on("-c", "--update-cookbooks", "Update the Chef cookbooks") do |update_cookbooks|
	    options[:update_cookbooks] = update_cookbooks
	  end
	  options[:chef] = true
	  opts.on("--[no-]chef", "Run chef (defaults to yes)") do |chef|
	    options[:chef] = chef
	  end
	  opts.separator ""
	  opts.separator "Common options:"
	  opts.on_tail("-h", "--help", "Show this message") do
	    puts opts
	    exit
	  end
	  opts.on_tail("--version", "Show version") do
	    puts "1.0.1"
	    exit
	  end
	end.parse!
	options
      end
    end
  end
end
