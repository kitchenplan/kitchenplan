require 'yaml'
require 'etc'
require 'ohai'
require 'erb'
require 'deep_merge'

require_relative 'cheffile'
require_relative 'template'

module Kitchenplan

  REMOTE_CONFIG = '.remote'

  class Config

    attr_reader :platform
    attr_reader :base_path
    attr_reader :default_config
    attr_reader :people_config
    attr_reader :group_configs

    def initialize
        self.detect_platform
        self.detect_base_path
        self.parse_default_config
        self.parse_people_config
        self.parse_group_configs
    end

    def detect_platform
        ohai = Ohai::System.new
        ohai.require_plugin("os")
        ohai.require_plugin("platform")
        @platform = ohai[:platform_family]
    end

    def detect_base_path
        base_path = "#{REMOTE_CONFIG}/config"
        @base_path = ( base_path if File.directory?(base_path) ) || 'config'
    end

    def parse_default_config
        default_config_path = "#{@base_path}/default.yml"
        @default_config = ( YAML.load(ERB.new(File.read(default_config_path)).result) if File.exist?(default_config_path) ) || {}
    end

    def parse_people_config
        people_config_path = "#{@base_path}/people/#{Etc.getlogin}.yml"
        @people_config = ( YAML.load(ERB.new(File.read(people_config_path)).result) if File.exist?(people_config_path) ) || YAML.load(ERB.new(File.read("#{@base_path}/people/roderik.yml")).result)
    end

    def parse_group_configs(group = @people_config['groups'])
        @group_configs = {}
        defined_groups = group || []
        defined_groups.each do |group|
            self.parse_group_config(group)
        end
    end

    def parse_group_config(group)
        unless @group_configs[group]
            group_config_path = "#{@base_path}/groups/#{group}.yml"
            @group_configs[group] = ( YAML.load(ERB.new(File.read(group_config_path)).result) if File.exist?(group_config_path) ) || {}
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
        config['attributes'] = {}
        config['attributes'].deep_merge!(@default_config['attributes'] || {}) { |key, old, new| Array.wrap(old) + Array.wrap(new) }
        @group_configs.each do |group_name, group_config|
            config['attributes'].deep_merge!(group_config['attributes']) { |key, old, new| Array.wrap(old) + Array.wrap(new) } unless group_config['attributes'].nil?
        end
        people_attributes = @people_config['attributes'] || {}
        config['attributes'].deep_merge!(people_attributes) { |key, old, new| Array.wrap(old) + Array.wrap(new) }
        config
    end

    def cheffile

      default_cheffile_path = "config/Cheffile"
      default_cheffile_temp = "templates/Cheffile.erb"
      custom_cheffile_path  = "#{REMOTE_CONFIG}/Cheffile"

      custom_cheffile  = ( Kitchenplan::Cheffile.new(custom_cheffile_path).result  if File.exist?(custom_cheffile_path) ) || {}
      default_cheffile = ( Kitchenplan::Cheffile.new(default_cheffile_path).result if File.exist?(default_cheffile_path) ) || {}
      cheffile_temp    = ( File.read(default_cheffile_temp) if File.exist?(default_cheffile_temp)) || ''

      cheffile = {
        :site => custom_cheffile[:site] || default_cheffile[:site],
        :cookbooks => (default_cheffile[:cookbooks] + (custom_cheffile[:cookbooks] || [])).group_by{|item| item[:name]}.map{|default,custom| custom.reduce(:merge)}
      }

      template = Kitchenplan::Template.render_from_hash(cheffile_temp, cheffile)
      template

    end

    private

    # Fetches the value at a path in a nested hash or nil if the path is not present.
    def hash_path(hash, *path)
        path.inject(hash) { |hash, key| hash[key] if hash }
    end

  end

end
