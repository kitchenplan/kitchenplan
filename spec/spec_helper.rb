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

require 'simplecov'
require 'chefspec'
require 'gabba'
require 'coveralls'

RSpec.configure do |config|
  config.before(:all) do
    @fake_ohai =
      {
	"fqdn" => "hostname.example.org",
	"hostname" => "hostname",
	"machinename" => "machinename",
	"platform" => "example-platform",
	"platform_version" => "example-platform-1.0",
	"platform_family" => "example",
	"data" => {}
      }
  end
end
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
      Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter "/spec/"
end
require 'kitchenplan'

FIXTURE_CONFIG_DIR = File.join((File.expand_path("../", Pathname.new(__FILE__).realpath)), "/support/fixtures/config")

Dir["./spec/support/**/*.rb"].each {|f| require f}

