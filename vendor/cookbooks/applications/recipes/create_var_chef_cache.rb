directory Chef::Config[:file_cache_path] do
  owner "root"
  group "admin"
  mode 0777
  action :create
  recursive true
end
