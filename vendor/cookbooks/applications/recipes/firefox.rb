dmg_package "Firefox" do
  source "http://download.mozilla.org/?product=firefox-18.0.2&os=osx&lang=en-US"
  action :install
  owner node['current_user']
end
