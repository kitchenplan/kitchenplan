require 'optparse'
class Kitchenplan
  # mixins!  we love them.
  module Mixin
    # option parsing utility class for command line applications.
    # note that this one is tuned exclusively for {Kitchenplan::Application}, which will
    # need to change if we ever add more apps.
    module Optparse
      # parse the command line with OptionParser and return the resulting config.
      def parse_commandline
	options = { 
	:debug => false,
	:config_dir => "config",
	:chef => true
	}
	OptionParser.new do |opts|
	  opts.banner = 'Usage: kitchenplan [options]'
	  opts.on("-d", "--debug", "Show debug information") do |debug|
	    options[:debug] = debug
	  end
	  options[:config_dir] = "config/"
	  opts.on("-c [DIRECTORY]", "--config-dir", "Path to YAML config directory") do |config_dir|
	    options[:config_dir] = config_dir
	  end
	  opts.on("-u", "--update-cookbooks", "Update the Chef cookbooks") do |update_cookbooks|
	    options[:update_cookbooks] = update_cookbooks
	  end
	  opts.on("--recipes x,y,z", Array, "Run Kitchenplan with all attributes, but only the recipes passed along on the command line. Useful for testing or fast runs.") do |list|
	            options[:recipes] = list
	  end
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
	    puts Kitchenplan::Version::VERSION
	    exit
	  end
	end.parse!
	options
      end
    end
  end
end
