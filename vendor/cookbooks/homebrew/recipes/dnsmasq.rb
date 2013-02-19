include_recipe "homebrew::default"

package "dnsmasq" do
  action :install
end

template "/usr/local/etc/dnsmasq.conf" do
    source "dnsmasq.conf.erb"
    owner node['current_user']
    mode "0755"
end

template "/Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist" do
    source "homebrew.mxcl.dnsmasq.plist.erb"
    owner "root"
    group "wheel"
    mode "0755"
end

directory "/etc/resolver" do
    owner "root"
    group "wheel"
end

template "/etc/resolver/dev" do
    source "resolver-dev.erb"
    owner "root"
    group "wheel"
    mode "0755"
end

service "homebrew.mxcl.dnsmasq" do
    action [ :start ]
end
