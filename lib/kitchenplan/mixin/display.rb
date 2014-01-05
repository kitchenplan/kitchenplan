module Kitchenplan
  module Mixin
    module Display
      module Tty extend self
	def blue; bold 34; end
	def white; bold 39; end
	def red; underline 31; end
	def reset; escape 0; end
	def bold n; escape "1;#{n}" end
	def underline n; escape "4;#{n}" end
	def escape n; "\033[#{n}m" if STDOUT.tty? end
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
    end
  end
end
class Array
  def shell_s
    cp = dup
    first = cp.shift
    cp.map{ |arg| arg.gsub " ", "\\ " }.unshift(first) * " "
  end
end
