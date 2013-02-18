# Chef package provider for Homebrew

require 'chef/provider/package'
require 'chef/resource/package'
require 'chef/platform'
require 'chef/mixin/shell_out'

class Chef
  class Provider
    class Package
      class Homebrew < Package

        include Chef::Mixin::ShellOut

        def load_current_resource
          @current_resource = Chef::Resource::Package.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)
          @current_resource.version(current_installed_version)

          @current_resource
        end

        def install_package(name, version)
          brew('install', @new_resource.options, name)
        end

        def upgrade_package(name, version)
          brew('upgrade', name)
        end

        def remove_package(name, version)
          brew('uninstall', @new_resource.options, name)
        end

        # Homebrew doesn't really have a notion of purging, so just remove.
        def purge_package(name, version)
          @new_resource.options = ((@new_resource.options || "") << " --force").strip
          remove_package(name, version)
        end

        protected
        def brew(*args)
          get_response_from_command("sudo -u #{node['current_user']} brew #{args.join(' ')}")
        end

        def current_installed_version
          pkg = get_version_from_formula
          versions = pkg.to_hash['installed'].map {|v| v['version']}
          versions.join(" ") unless versions.empty?
        end

        def candidate_version
          pkg = get_version_from_formula
          pkg.stable.version.to_s || pkg.version.to_s
        end

        def get_version_from_command(command)
          version = get_response_from_command(command).chomp
          version.empty? ? nil : version
        end

        def get_version_from_formula
          brew_cmd = shell_out!("sudo -u #{node['current_user']} brew --prefix")
          libpath = ::File.join(brew_cmd.stdout.chomp, "Library", "Homebrew")
          $:.unshift(libpath)

          require 'global'
          require 'cmd/info'

          Formula.factory new_resource.package_name
        end

        def get_response_from_command(command)
          output = shell_out!(command)
          output.stdout
        end
      end
    end
  end
end

Chef::Platform.set :platform => :mac_os_x, :resource => :package, :provider => Chef::Provider::Package::Homebrew
