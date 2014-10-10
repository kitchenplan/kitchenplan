require 'yaml'
require 'etc'
#require 'ohai'
require 'erb'
require 'deep_merge'

module Kitchenplan

  class Config

    attr_reader :platform
    attr_reader :default_config
    attr_reader :people_config
    attr_reader :system_config
    attr_reader :group_configs

    def initialize
      self.detect_platform
      self.parse_default_config
      self.parse_people_config
      self.parse_system_config
      self.parse_group_configs
    end

    def detect_platform
      #ohai = Ohai::System.new
      #ohai.require_plugin('os')
      #ohai.require_plugin('platform')
      #@platform = ohai[:platform_family]
      @platform = 'mac_os_x' # We only support osx at the moment, and it saves a large dependency
    end

   def hardware_model
      `sysctl -n hw.model | tr -d '\n'`
   end

    def parse_default_config
      default_config_path = 'config/default.yml'
      @default_config = (YAML.load(ERB.new(File.read(default_config_path)).result) if File.exist?(default_config_path)) || {}
    end

    def parse_people_config
      people_config_path = "config/people/#{Etc.getlogin}.yml"
      @people_config = (YAML.load(ERB.new(File.read(people_config_path)).result) if File.exist?(people_config_path)) || {}
    end

    def parse_system_config
      system_config_path = "config/system/#{hardware_model}.yml"
      @system_config = (YAML.load(ERB.new(File.read(system_config_path)).result) if File.exist?(system_config_path)) || {}
    end

    def parse_group_configs(group = (( @default_config['groups'] || [] ) | ( @people_config['groups'] || [] )))
      @group_configs = @group_configs || {}
      defined_groups = group || []
      defined_groups.each do |group|
        self.parse_group_config(group)
      end
    end

    def parse_group_config(group)
      unless @group_configs[group]
        group_config_path = "config/groups/#{group}.yml"
        @group_configs[group] = (YAML.load(ERB.new(File.read(group_config_path)).result) if File.exist?(group_config_path)) || {}
        defined_groups = @group_configs[group]['groups']
        if defined_groups
          self.parse_group_configs(defined_groups)
        end
      end
    end

    def config
      config = {}
      config['recipes'] = []
      config['recipes'] |= hash_path(@default_config, 'recipes', 'global') || []
      config['recipes'] |= hash_path(@default_config, 'recipes', @platform) || []
      @group_configs.each do |group_name, group_config|
        config['recipes'] |= hash_path(group_config, 'recipes', 'global') || []
        config['recipes'] |= hash_path(group_config, 'recipes', @platform) || []
      end
      people_recipes = @people_config['recipes'] || {}
      config['recipes'] |= people_recipes['global'] || []
      config['recipes'] |= people_recipes[@platform] || []
          
      system_recipes = @system_config['recipes'] || {}  
      config['recipes'] |= system_recipes['global'] || []
      config['recipes'] |= system_recipes[@platform] || []

      # First take the attributes from default.yml
      config['attributes'] = {}
      config['attributes'].deep_merge!(@default_config['attributes'] || {}) { |key, old, new| Array.wrap(old) + Array.wrap(new) }

      # then override and extend them with the group attributes
      @group_configs.each do |group_name, group_config|
        config['attributes'].deep_merge!(group_config['attributes']) { |key, old, new| Array.wrap(old) + Array.wrap(new) } unless group_config['attributes'].nil?
      end

      # then override and extend them with the people attributes
      people_attributes = @people_config['attributes'] || {}
      config['attributes'].deep_merge!(people_attributes) { |key, old, new| Array.wrap(old) + Array.wrap(new) }

      # lastly override from the system files
      system_attributes = @system_config['attributes'] || {}
      config['attributes'].deep_merge!(system_attributes) { |key, old, new| Array.wrap(old) + Array.wrap(new) }

      config
    end

    private

    # Fetches the value at a path in a nested hash or nil if the path is not present.
    def hash_path(hash, *path)
      path.inject(hash) { |hash, key| hash[key] if hash }
    end

  end

end
