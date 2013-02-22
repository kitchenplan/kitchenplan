dmg_package "Alfred" do
  volumes_dir "Alfred.app"
  source "http://media.alfredapp.com/alfred_1.3.3_267.zip"
  action :install
  owner node['current_user']
end
