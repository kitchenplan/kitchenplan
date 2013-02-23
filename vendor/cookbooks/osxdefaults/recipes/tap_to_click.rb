osxdefaults_defaults "Tap to click 1/3" do
  domain 'com.apple.driver.AppleBluetoothMultitouch.trackpad'
  key 'Clicking'
  boolean true
end

osxdefaults_defaults "Tap to click 2/3" do
  domain 'NSGlobalDomain'
  key 'com.apple.mouse.tapBehavior'
  integer 1
end

osxdefaults_defaults "Tap to click 3/3" do
  domain 'com.apple.mouse.tapBehaviour'
  integer 1
end
