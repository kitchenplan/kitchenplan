require 'kitchenplan/mixins'
require 'kitchenplan/config'
# platform-specificity
require 'kitchenplan/platform'
require "kitchenplan/platform/#{Kitchenplan::Config.new().platform}"
