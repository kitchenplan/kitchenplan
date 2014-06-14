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

require 'optparse'
require 'kitchenplan'


class Kitchenplan
  # application class is the class invoked by bin/kitchenplan.  this is where almost all of the
  # heavy lifting for the app happens.
  class Application < Kitchenplan
    attr_accessor :options, :config
    # Main point of entry for kitchenplan binary.  #run starts the app.
    def initialize(bare=false,argv=ARGV)
      Kitchenplan::Log.info "Kitchenplan starting up."
      unless bare == true
	prepare(argv)
      end
    end
    def prepare(argv=ARGV)
      # get command-line options.
      self.options = parse_commandline(argv)
      configure_logging(loglevel=options[:log_level].to_sym)
      detect_platform()
      detect_resolver()
      load_config()
      if options[:log_level] == "debug"
	self.resolver.debug = true
      end
    end
    # Ensure that we can gracefully and quickly terminate.  People love that.
    def trap_signals
      trap("TERM") do
	self.fatal!("TERM received",1)
      end

      trap("INT") do
	self.fatal!("Interrupt signal received.", 2)
      end
    end
    # set up the admittedly Chef-style logger facility
    # Except that we don't log anywhere but STDOUT right now.
    def configure_logging(loglevel)
      return if loglevel == :none
      if self.options[:log_file].nil?
	Kitchenplan::Log.init(Kitchenplan::Log::MultiIO.new(STDOUT))
      else
	file = File.open(options[:log_file],"a")
	Kitchenplan::Log.init(Kitchenplan::Log::MultiIO.new(STDOUT,file))
      end
      Kitchenplan::Log.level = loglevel
    end
    # load our application config and make it available elsewhere.
    def load_config()
      Kitchenplan::Log.debug "Loading configs from #{self.options[:config_dir]} ..."
      Kitchenplan::Log.debug self.platform.ohai.inspect
      self.config = Kitchenplan::Config.new(self.platform.ohai, parse_configs=true,config_path=self.options[:config_dir]).config()
    end
    # Generate Chef configs based on the merged Kitchenplan config hints and run lists.
    def generate_chef_config()
      Kitchenplan::Log.debug "Truncating kitchenplan-attributes.json ..."
      File.open("kitchenplan-attributes.json", 'w') do |out|
	out.write(::JSON.pretty_generate(self.config['attributes']))
      end
      Kitchenplan::Log.debug "Truncating solo.rb ..."
      File.open("solo.rb", 'w') do |out|
	out.write("cookbook_path      [ \"#{Dir.pwd}/cookbooks\" ]")
      end
      Kitchenplan::Log.debug "Done writing Chef configs."
    end
    # using our chosen resolver, ensure that our cookbooks/ directory is up-to-date before we run Chef.
    def update_cookbooks()
      unless File.exists?("cookbooks")
	Kitchenplan::Log.info "No cookbooks directory found.  Running #{self.resolver.name} to download necessary cookbooks."
	self.platform.normaldo self.resolver.fetch_dependencies()
      end
      if self.options[:update_cookbooks]
	Kitchenplan::Log.info "Updating cookbooks with #{self.resolver.name}"
	self.platform.normaldo self.resolver.update_dependencies()
      end
    end
    # let us know who's running Kitchenplan.
    def ping_google_analytics()
      # Trying to get some metrics for usage, just comment out if you don't want it.
      Kitchenplan::Log.info 'Sending a ping to Google Analytics to count usage'
      require 'gabba'
      Gabba::Gabba.new("UA-46288146-1", "github.com").event("Kitchenplan", "Run", ENV['USER'])
    end
    # main point of entry for the class.
    def run
      begin
      Kitchenplan::Log.info "Kitchenplan run ready to begin."
      Kitchenplan::Log.debug "Started with options: #{options.inspect}"
      Kitchenplan::Log.info "Validating dependencies for platform '#{self.platform.name}'..."
      self.platform.prerequisites()
      if self.resolver.name == "undefined"
	Kitchenplan::Log.info "Checking for resolvers again now that dependencies are satisfied ... "
	self.resolver = nil
	detect_resolver()
      end
      Kitchenplan::Log.info "Generating Chef configs..."
      generate_chef_config()
      Kitchenplan::Log.info "Verifying cookbook dependencies using '#{self.resolver.name}'..."
      ping_google_analytics()
      update_cookbooks()
      use_solo = options[:chef_mode].include?("solo") ? true : false
      log_level = options[:log_level]
      log_file = options[:log_file]
      recipes = self.config['recipes']
      self.platform.sudo(self.platform.run_chef(use_solo=use_solo,log_level=log_level,log_file=log_file,recipes=recipes))
      Kitchenplan::Log.info "Chef run completed."
      self.exit!("Kitchenplan run complete.  Exiting normally.")
      rescue RuntimeError => e
	Kitchenplan::Log.error "An error was encountered shelling out and running a command to configure your system."
	Kitchenplan::Log.error "This could be due to a bug in Kitchenplan or an unexpected configuration on your system."
	Kitchenplan::Log.error "Failed command: #{e.message}"
	Kitchenplan::Log.error "Stack trace:"
	e.backtrace.each { |l| Kitchenplan::Log.error "  #{l}" }
	self.fatal!("Kitchenplan could not run successfully and is exiting with errors.",-2)
      end
    end
    def parse_commandline(argv=ARGV)
      options = {
	:config_dir => "config",
	:log_level => "info",
	:log_file => nil,
	:chef => true,
	:chef_mode => "solo"
      }
      OptionParser.new do |opts|
	opts.banner = 'Usage: kitchenplan [options]'
	options[:config_dir] = "config/"
	opts.on("-c [DIRECTORY]", "--config-dir", "Path to YAML config directory") do |config_dir|
	  options[:config_dir] = config_dir
	end
	opts.on("-l [SEVERITY]", "--log-level", "Amount of logging detail (error, warn, info, debug)") do |log_level|
	  options[:log_level] = log_level
	end
	opts.on("--log-file [FILENAME]", "Path to log file for Kitchenplan and resulting Chef runs") do |log_file|
	  options[:log_file] = log_file
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
	opts.on("-m [CHEFMODE]","--chef-mode", "Run chef-solo or chef-client using chef-zero (solo|zero)") do |chefmode|
	  options[:chef_mode] = chefmode
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
      end.parse!(argv)
      options
    end
    # In a Chef-like manner, log a fatal message to stderr/logger and exit with this error code.
    def fatal!(msg, err = -1)
      Kitchenplan::Log.fatal(msg)
      Process.exit err
    end
    # In a Chef-like manner, log a debug message to the logger and exit with this error code.
    def exit!(msg, err = -1)
      Kitchenplan::Log.debug(msg)
      Process.exit err
    end
  end
end
