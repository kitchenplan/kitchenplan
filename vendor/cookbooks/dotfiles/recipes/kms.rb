include_recipe 'homebrew::git'
include_recipe 'dotfiles::bash_it'

# Getting the kms sources

git "/opt/kms" do
  repository "https://github.com/Kunstmaan/kms.git"
  reference "master"
  action :sync
end

directory "/opt/kms" do
  owner node['current_user']
  group "admin"
  mode 0777
  recursive true
  action :create
end

# Add to the bash_profile settings
dotfiles_bash_it_custom_plugin "bash_it/custom/kms.bash"
