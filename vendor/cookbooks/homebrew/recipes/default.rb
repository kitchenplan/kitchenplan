directory "/usr/local" do
  owner node['current_user']
  recursive true
end

homebrew_go = "#{Chef::Config[:file_cache_path]}/homebrew_go"

remote_file homebrew_go do
    source "https://raw.github.com/mxcl/homebrew/go"
    mode 00755
end

execute homebrew_go do
    user node['current_user']
    not_if { File.exist? '/usr/local/bin/brew' }
end

execute "update homebrew from github" do
    command "/usr/local/bin/brew update || true"
end
