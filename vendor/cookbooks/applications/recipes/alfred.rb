dmg_package "Alfred" do
  volumes_dir "Alfred.app"
  source "http://cachefly.alfredapp.com/alfred_1.3.2_265.zip"
  action :install
  owner node['current_user']
end
