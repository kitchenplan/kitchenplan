dmg_package "Firefox" do
  source "ftp://ftp.mozilla.org/pub/mozilla.org/firefox/releases/19.0/mac/en-US/Firefox%2019.0.dmg"
  action :install
  owner node['current_user']
end
