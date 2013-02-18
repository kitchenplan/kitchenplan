dmg_package "Evernote" do
  volumes_dir "Evernote"
  source "http://evernote.com/download/get.php?file=EvernoteMac"
  accept_eula true
  action :install
  owner node['current_user']
end
