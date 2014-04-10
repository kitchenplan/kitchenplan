require 'simplecov'
require 'chefspec'

SimpleCov.start
require 'kitchenplan'

FIXTURE_CONFIG_DIR = File.join((File.expand_path("../", Pathname.new(__FILE__).realpath)), "/support/fixtures/config")

Dir["./spec/support/**/*.rb"].each {|f| require f}

