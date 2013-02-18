osxdefaults_defaults "Save screenshots to the desktop" do
  domain 'com.apple.screencapture'
  key 'location'
  string "#{node['etc']['passwd'][node['current_user']]['dir']}/Desktop"
end
