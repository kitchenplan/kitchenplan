require 'yaml'
require 'etc'
require 'deep_merge'
require 'erubis'

class Kitchenplan
  # standalone class that parses YAML configs in a supplied config directory (./config, by default) ...
  # TODO: some of this could stand to be refactored.
  class Config

    # the path to the config directory
    attr_accessor :config_path
    attr_reader :ohai
    # parsed contents of the default config file (usually /default.yml)
    attr_reader :default_config
    # parsed contents of the config file for the logged-in user (usually /people/USERNAME.yml)
    attr_reader :people_config
    # array of parsed contents of group config files associated with the logged-in user or the default config
    # (drawn from /groups/GROUPNAME.yml)
    attr_reader :group_configs

    # constructor parameters:
    #  ohai = ohai data from the run used to determine the current platform.
    #  this gets passed to the erubis template engine for greater flexibility in YAML configs.
    #  parse_configs = should configs be parsed automatically on instantiation?
    #  config_path = default relative path for configuration files.
    def initialize(ohai, parse_configs=true,config_path="config")
      self.config_path=config_path
      @group_configs = {}
      @default_config = {}
      @people_config = {}
      @ohai = ohai

      if parse_configs == true
        Kitchenplan::Log.debug "Kitchenplan::Config: Parsing configs from #{config_path} on init"
        self.do_parse_configs(config_path)
      end
    end

    def do_parse_configs(config_path=self.config_path)
      self.config_path = config_path
      Kitchenplan::Log.debug "Now parsing configs in #{self.config_path}..."
      self.parse_default_config
      self.parse_people_config
      self.parse_group_configs
    end


    # parse the default global config file.
    def parse_default_config
      default_config_path = "#{self.config_path}/default.yml"
      @default_config = parse_config(default_config_path)
    end

    # parse the current user's config file.  if no such file exists, fall back to the default person account.
    # currently the default account is roderik's.
    def parse_people_config
      people_config_path = "#{self.config_path}/people/#{Etc.getlogin}.yml"
      begin
        @people_config = parse_config(people_config_path)
      rescue LoadError
        Kitchenplan::Log.warn "No personal config file found.  Defaulting to #{self.config_path}/people/roderik.yml"
        @people_config = parse_config("#{self.config_path}/people/roderik.yml")
      end
    end

    # find and parse each group named in a person's config file.
    def parse_group_configs(group = (( @default_config['groups'] || [] ) | ( @people_config['groups'] || [] )))
        @group_configs = @group_configs || {}
        defined_groups = group || []
        defined_groups.each do |group|
            self.parse_group_config(group)
        end
    end

    # parse configuration for a named group file.
    def parse_group_config(group)
        unless @group_configs.nil? == false and @group_configs.empty? == false and @group_configs[group]
            group_config_path = "#{self.config_path}/groups/#{group}.yml"
            @group_configs[group] = parse_config(group_config_path)
            defined_groups = @group_configs[group]['groups']
            if defined_groups
                self.parse_group_configs(defined_groups)
            end
        end
    end

    # generic config file parser.  give it a file, it parses it, no muss, no fuss, raises valid exceptions.
    # bonus feature: we pass in the ohai data as an object in the 'node' namespace, which should be familiar
    # territory for anyone who's worked with chef...
    def parse_config(filename)
      begin
            Kitchenplan::Log.debug "parse_config(): Loading file: #{filename}"
            ( YAML.load(Erubis::Eruby.new(File.read(filename)).evaluate(:node => self.ohai)) if File.exist?(filename) ) || {}
      rescue Psych::SyntaxError => e
        Kitchenplan::Log.error "There was an error parsing config file #{filename}: #{e.message}"
        raise StandardError, "Error parsing #{filename}: #{e.message}"
      end
    end

    # for the current user and relevant groups and current platform,
    # merge down all the relevant attributes and recipes into a config object with two keys:
    #   'recipes' => chef run list
    #   'attributes' => chef node attributes
    def config
        config = {}
        config['recipes'] = []
        config['recipes'] |= hash_path(@default_config, 'recipes', 'global') || []
        config['recipes'] |= hash_path(@default_config, 'recipes', self.ohai["platform_family"]) || []
        @group_configs.each do |group_name, group_config|
            config['recipes'] |= hash_path(group_config, 'recipes', 'global') || []
            config['recipes'] |= hash_path(group_config, 'recipes', self.ohai["platform_family"]) || []
        end
        people_recipes = @people_config['recipes'] || {}
        config['recipes'] |= people_recipes['global'] || []
        config['recipes'] |= people_recipes[self.ohai["platform_family"]] || []
        config['attributes'] = {}
        config['attributes'].deep_merge!(@default_config['attributes'] || {}) { |key, old, new| Array.wrap(old) + Array.wrap(new) }
        @group_configs.each do |group_name, group_config|
            config['attributes'].deep_merge!(group_config['attributes']) { |key, old, new| Array.wrap(old) + Array.wrap(new) } unless group_config['attributes'].nil?
        end
        people_attributes = @people_config['attributes'] || {}
        Kitchenplan::Log.debug "config(): @people_config = #{@people_config.inspect}"
        Kitchenplan::Log.debug "config(): @group_configs = #{@group_configs.inspect}"
        Kitchenplan::Log.debug "config(): @default_config = #{@default_config.inspect}"
        config['attributes'].deep_merge!(people_attributes) { |key, old, new| Array.wrap(old) + Array.wrap(new) }
        config
    end

    private

    # Fetches the value at a path in a nested hash or nil if the path is not present.
    def hash_path(hash, *path)
        path.inject(hash) { |hash, key| hash[key] if hash }
    end

  end

end
