execute "set ComputerName" do
    command "scutil --set ComputerName #{node['osxdefaults']['computername']}"
end

execute "set HostName" do
    command "scutil --set HostName #{node['osxdefaults']['computername']}"
end

execute "set LocalHostName" do
    command "scutil --set LocalHostName #{node['osxdefaults']['computername']}"
end

osxdefaults_defaults "Set the computer name" do
  domain 'com.apple.smb.server'
  key 'NetBIOSName'
  string node['osxdefaults']['computername']
end
