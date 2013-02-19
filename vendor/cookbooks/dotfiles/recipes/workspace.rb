directory "#{node['etc']['passwd'][node['current_user']]['dir']}/Development" do
    owner node['current_user']
end
