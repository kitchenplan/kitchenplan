include_recipe "homebrew::default"

package "gnu-tar" do
  action :install
end

link "/usr/bin/tar" do
    to "/usr/local/bin/gtar"
end
