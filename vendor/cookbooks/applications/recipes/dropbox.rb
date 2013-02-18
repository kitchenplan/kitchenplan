dmg_package "Dropbox" do
  volumes_dir "Dropbox Installer"
  source "https://www.dropbox.com/download?plat=mac"
  action :install
  owner node['current_user']
end
