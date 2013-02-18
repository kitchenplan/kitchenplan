dmg_package "VirtualBox" do
  source "http://download.virtualbox.org/virtualbox/4.2.6/VirtualBox-4.2.6-82870-OSX.dmg"
  action :install
  owner node['current_user']
  type "pkg"
  package_id "org.virtualbox.pkg.virtualbox"
end
