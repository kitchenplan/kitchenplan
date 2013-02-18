if node["platform"] == "ubuntu"
    template "/etc/gitconfig" do
        source "gitconfig.erb"
        owner "root"
        mode "0755"
    end
else
    template "#{node['etc']['passwd'][node['current_user']]['dir']}/.gitconfig" do
        source "gitconfig.erb"
        owner "root"
        mode "0755"
    end
end

template "/etc/gitignore" do
    source "gitignore.erb"
    owner "root"
    mode "0755"
end

execute "set git system credential helper" do
    command "git config --global credential.helper osxkeychain"
    user node['current_user']
    only_if { node["platform"] == "mac_os_x" }
end

execute "set user name" do
    command "git config --global user.name \"#{node["git"]["name"]}\""
    user node['current_user']
    only_if node.attribute?("git_name")
end

execute "set user email" do
    command "git config --global user.email \"#{node["git"]["email"]}\""
    user node['current_user']
    only_if node.attribute?("git_email")
end
