dmg_package "SuperDuper!" do
  source "http://www.shirt-pocket.com/mint/pepper/orderedlist/downloads/download.php?file=http%3A//www.shirt-pocket.com/downloads/SuperDuper%21.dmg"
  accept_eula true
  action :install
  owner node['current_user']
end
