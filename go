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

GO_SCRIPT_VERSION = '1.0.0'

KITCHENPLAN_PATH = ENV.fetch("KITCHENPLAN_PATH", "/opt/kitchenplan")
KITCHENPLAN_REPO = ENV.fetch("KITCHENPLAN_REPO", "https://github.com/kitchenplan/kitchenplan.git")

require 'optparse'
options = {}
OptionParser.new do |opts|
    opts.banner = 'Usage: go [options]'

    options[:interaction] = true
    opts.on("--[no-]interaction", "Run the go script without user interaction") do |interaction|
	options[:interaction] = interaction
    end

    opts.separator ""
    opts.separator "Common options:"

    opts.on_tail("-h", "--help", "Show this message") do
	puts opts
	exit
    end

    opts.on_tail("--version", "Show version") do
	puts GO_SCRIPT_VERSION
	exit
    end

end.parse!

module Tty extend self
  def blue; bold 34; end
  def white; bold 39; end
  def red; underline 31; end
  def reset; escape 0; end
  def bold n; escape "1;#{n}" end
  def underline n; escape "4;#{n}" end
  def escape n; "\033[#{n}m" if STDOUT.tty? end
end

class Array
  def shell_s
    cp = dup
    first = cp.shift
    cp.map{ |arg| arg.gsub " ", "\\ " }.unshift(first) * " "
  end
end

def ohai *args
  puts "#{Tty.blue}==>#{Tty.white} #{args.shell_s}#{Tty.reset}"
end

def warn warning
  puts "#{Tty.red}Warning#{Tty.reset}: #{warning.chomp}"
end

def system *args
  abort "Failed during: #{args.shell_s}" unless Kernel.system *args
end

def warnandexit message
  warn message
  exit
end

def sudo *args
  args = if args.length > 1
    args.unshift "/usr/bin/sudo"
  else
    "/usr/bin/sudo #{args.first}"
  end
  ohai *args
  system *args
end

def normaldo *args
  ohai *args
  system *args
end

def getc  # NOTE only tested on OS X
  system "/bin/stty raw -echo"
  if RUBY_VERSION >= '1.8.7'
    STDIN.getbyte
  else
    STDIN.getc
  end
ensure
  system "/bin/stty -raw echo"
end

def wait_for_user
  puts
  puts "Press ENTER to continue or any other key to abort"
  puts
  c = getc
  # we test for \r and \n because some stuff does \r instead
  abort unless c == 13 or c == 10
end

def macos_version
  @macos_version ||= `/usr/bin/sw_vers -productVersion`.chomp[/10\.\d+/]
end

######################################################

ohai "Kitchenplan is only tested on 10.8 and 10.9, proceed on your own risk." if macos_version < "10.8"
wait_for_user if macos_version < "10.8"
#abort "OSX too old, you need at least Mountain Lion" if macos_version < "10.8"

abort "Don't run this as root!" if Process.uid == 0
abort <<-EOABORT unless `groups`.split.include? "admin"
This script requires the user #{ENV['USER']} to be an Administrator.
EOABORT

if macos_version < "10.9" and macos_version > "10.6"
  `/usr/bin/cc --version 2> /dev/null` =~ %r[clang-(\d{2,})]
  version = $1.to_i
  warnandexit %{Install the "Command Line Tools for Xcode": https://developer.apple.com/downloads/} if version < 425
else
  warnandexit "Install Xcode: https://developer.apple.com/xcode/" unless File.exist? "/usr/bin/cc"
end

ohai "This script will install:"
puts "  - Command Line Tools if they are not installed"
puts "  - Chef"
puts "  - All applications configured in <yourusername>.yml or if not available roderik.yml"
puts ""
warn "Unless by chance your user is also named Roderik, and you want exactly the same applications as I, use the KITCHENPLAN_REPO env to point to a fork with a config file named for your username."
puts ""

wait_for_user if options[:interaction]

if macos_version > "10.8"
  unless File.exist? "/Library/Developer/CommandLineTools/usr/bin/clang"
    ohai "Installing the Command Line Tools (expect a GUI popup):"
    sudo "/usr/bin/xcode-select", "--install"
    puts "Press any key when the installation has completed."
    getc
  end
end

if File.directory?(KITCHENPLAN_PATH)
  ohai "Updating existing kitchenplan installation..."
  Dir.chdir KITCHENPLAN_PATH
  normaldo "git pull"
else
  ohai "Setting up the Kitchenplan installation..."
  sudo "mkdir -p /opt"
  sudo "chown -R #{ENV["USER"]} /opt"
  normaldo "git clone -q #{KITCHENPLAN_REPO} #{KITCHENPLAN_PATH}"
end

Dir.chdir KITCHENPLAN_PATH if options[:interaction]
normaldo "./kitchenplan"
