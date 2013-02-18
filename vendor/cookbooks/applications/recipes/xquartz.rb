dmg_package "XQuartz" do
  source "http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.4.dmg"
  action :install
  volumes_dir "XQuartz-2.7.4"
  type "pkg"
  owner node['current_user']
  package_id "org.macosforge.xquartz.pkg"
end
