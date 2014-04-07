class Kitchenplan
  module Mixin
    # Display module contains logging / color methods.  Mainly used in old kitchenplan.
    module Display
      # TTY mix-ins for pretty printing.  
      # TODO: These can probably be removed now.
      module Tty extend self
	# change color to blue.
	def blue; bold 34; end
	# change color to white.
	def white; bold 39; end
	# change color to red.
	def red; underline 31; end
	# change color back to normal (usually grey).
	def reset; escape 0; end
	# set text to bold (usually underline/bright).
	def bold n; escape "1;#{n}" end
	# set text to underline.
	def underline n; escape "4;#{n}" end
	# print ANSI/VT-100 terminal escape.
	def escape n; "\033[#{n}m" if STDOUT.tty? end
      end
      # ohai output formatting
      def ohai *args
	puts "#{Tty.blue}==>#{Tty.white} #{args.shell_s}#{Tty.reset}"
      end
      # warn message formatting
      def warn warning
	puts "#{Tty.red}Warning#{Tty.reset}: #{warning.chomp}"
      end
      # run system command
      def system *args
	abort "Failed during: #{args.shell_s}" unless Kernel.system *args
      end
      # emit warning message and exit sanely.
      def warnandexit message
	warn message
	exit
      end
    end
  end
end
# we are redefining Array here for some reason.
# TODO: Figure out why we redefine array.
class Array
  # we are monkeypatching #shell_s for some reason.
  # TODO: Figure out why we redefine {Array#shell_s}.
  def shell_s
    cp = dup
    first = cp.shift
    cp.map{ |arg| arg.gsub " ", "\\ " }.unshift(first) * " "
  end
end
