#!/usr/bin/env ruby

# installation script modeled after homebrew
# see https://raw.github.com/mxcl/homebrew/go
#
# script is re-runnable and will automatically update an existing installation
# with the latest changes before installing new recipes.
#
# example execution:
#   $ ruby -e "$(curl -fsSL https://raw.github.com/kitchenplan/kitchenplan/master/go)"
#
# execution can be customized by the following environmental variables:
# KITCHENPLAN_PATH - kitchenplan installation path (defaults to /opt/kitchenplan)
# KITCHENPLAN_REPO - repository to use for recipes/cookbooks (defaults to https://github.com/kitchenplan/kitchenplan)

KITCHENPLAN_PATH = ENV.fetch("KITCHENPLAN_PATH", "/opt/kitchenplan")
KITCHENPLAN_REPO = ENV.fetch("KITCHENPLAN_REPO", "https://github.com/kitchenplan/kitchenplan.git")

# execute a shell command and raise an error if non-zero exit code is returned
def run_cmd(cmd, options = {})
  puts "$ #{cmd}"
  success = system(cmd)
  fail "#{cmd} failed" unless success || options[:allow_failure]
end

# check if xcode command line tools are installed
def xcode_cli_installed?
  xcode_path = `xcode-select -p`
  xcode_cli_installed = $?.to_i == 0
end

run_cmd 'xcode-select --install' unless xcode_cli_installed?

if File.directory?(KITCHENPLAN_PATH)
  puts "Updating existing kitchenplan installation..."
  Dir.chdir KITCHENPLAN_PATH
  run_cmd "git pull"
else
  run_cmd "sudo mkdir -p /opt"
  run_cmd "sudo chown -R #{ENV["USER"]} /opt"
  run_cmd "git clone #{KITCHENPLAN_REPO} #{KITCHENPLAN_PATH}"
end

Dir.chdir KITCHENPLAN_PATH
run_cmd "./kitchenplan"
