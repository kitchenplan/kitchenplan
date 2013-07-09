require 'yaml'
require 'etc'
require 'ohai'

module Kitchenplan

  class Config

    attr_reader :platform
    attr_reader :default_config
    attr_reader :people_config
    attr_reader :group_configs

    def initialize
        self.detect_platform
        self.parse_default_config
        self.parse_people_config
        self.parse_group_configs
    end

    def detect_platform
        ohai = Ohai::System.new
        ohai.all_plugins
        @platform = ohai[:platform_family]
    end

    def parse_default_config
        default_config_path = 'config/default.yml'
        @default_config = ( YAML.load_file(default_config_path) if File.exist?(default_config_path) ) || {}
    end

    def parse_people_config
        people_config_path = "config/people/#{Etc.getlogin}.yml"
        @people_config = ( YAML.load_file(people_config_path) if File.exist?(people_config_path) ) || {}
    end

    def parse_group_configs
        @group_configs = {}
        defined_groups = @people_config['groups'] || []
        defined_groups.each do |group|
            self.parse_group_config(group)
        end
    end

    def parse_group_config(group)
        group_config_path = "config/groups/#{group}.yml"
        @group_configs[group] = ( YAML.load_file(group_config_path) if File.exist?(group_config_path) ) || {}
    end

    def config
        config = {}
        config['recipes'] = []
        config['recipes'] |= @default_config['recipes']['global'] || []
        config['recipes'] |= @default_config['recipes'][@platform] || []
        @group_configs.each do |group_name, group_config|
            config['recipes'] |= group_config['recipes']['global'] || []
            config['recipes'] |= group_config['recipes'][@platform] || []
        end
        people_recipes = @people_config['recipes'] || {}
        config['recipes'] |= people_recipes['global'] || []
        config['recipes'] |= people_recipes[@platform] || []
        config['attributes'] = {}
        config['attributes'].merge!(@default_config['attributes'])
        @group_configs.each do |group_name, group_config|
            config['attributes'].merge!(group_config['attributes']) unless group_config['attributes'].nil?
        end
        people_attributes = @people_config['attributes'] || {}
        config['attributes'].merge!(people_attributes)
        config
    end

  end

end
