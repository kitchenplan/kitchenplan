dmg_package "Firefox" do
  source "https://download.mozilla.org/?product=firefox-19.0&os=osx&lang=en-US"
  action :install
  owner node['current_user']
end
