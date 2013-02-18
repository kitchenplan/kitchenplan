include_recipe "homebrew::default"
include_recipe "homebrew::bash-completion"

package "git" do
  action :install
end
