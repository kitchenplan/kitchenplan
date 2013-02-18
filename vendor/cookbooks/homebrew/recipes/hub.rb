include_recipe "homebrew::default"
include_recipe "homebrew::bash-completion"
include_recipe "homebrew::git"

package "hub" do
  action :install
end
