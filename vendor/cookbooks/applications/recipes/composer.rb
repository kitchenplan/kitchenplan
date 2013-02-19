composer "/usr/local/bin" do
  owner "root" # optional
  action [:install, :update]
end
