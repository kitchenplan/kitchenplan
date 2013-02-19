unless File.exists?("#{Chef::Config[:file_cache_path]}/XC_Integrated550_560_v1_1_RBpDX_FD44_v4.dmg")
    remote_file "#{Chef::Config[:file_cache_path]}/Integrated550_560-MAC-10.6_7_8-Driver-3.3.004.1.zip" do
        source "http://download.support.xerox.com/pub/drivers/550_560_DCP/drivers/macosx106/ar/Integrated550_560-MAC-10.6_7_8-Driver-3.3.004.1.zip"
        owner node['current_user']
    end

    execute "unzip the xerox550 driver 1/3" do
        command "unzip -u #{Chef::Config[:file_cache_path]}/Integrated550_560-MAC-10.6_7_8-Driver-3.3.004.1.zip -d #{Chef::Config[:file_cache_path]}/"
        user node['current_user']
    end

    execute "unzip the xerox550 driver 2/3" do
        command "unzip -u #{Chef::Config[:file_cache_path]}/Integrated550_560-MAC-10.6_7_8-Driver-3.3.004.1/1-1G3Z0Z_XC_Integrated550_560_v1_1_RBpDX_FD44_v4.zip -d #{Chef::Config[:file_cache_path]}/Integrated550_560-MAC-10.6_7_8-Driver-3.3.004.1/"
        user node['current_user']
    end

    execute "unzip the xerox550 driver 3/3" do
        command "unzip -u #{Chef::Config[:file_cache_path]}/Integrated550_560-MAC-10.6_7_8-Driver-3.3.004.1/XC_Integrated550_560_v1_1_RBpDX_FD44_v4.zip -d #{Chef::Config[:file_cache_path]}/"
        user node['current_user']
    end

    directory "#{Chef::Config[:file_cache_path]}/Integrated550_560-MAC-10.6_7_8-Driver-3.3.004.1" do
      recursive true
      action :delete
    end

    file "#{Chef::Config[:file_cache_path]}/Integrated550_560-MAC-10.6_7_8-Driver-3.3.004.1.zip" do
        action :delete
    end
end

execute "attach XC_Integrated550_560_v1_1_RBpDX_FD44_v4.dmg" do
    command "hdiutil attach '#{Chef::Config[:file_cache_path]}/XC_Integrated550_560_v1_1_RBpDX_FD44_v4.dmg'"
    user node['current_user']
    not_if "lpstat -v | grep -q 'Xerox-550'"
end

execute "install Xerox-550" do
    command "\"/Volumes/User Software/Fiery Driver Installer.app/Contents/MacOS/./installer.sh\"  -i #{node['drivers']['xerox']} -l en_us -p \"/Volumes/User Software/Fiery Driver Installer.app/Contents/Resources/User Software/OSX/Printer Driver/OSX installer.pkg\" -printer \"Xerox-550\""
    not_if "lpstat -v | grep -q 'Xerox-550'"
end

execute "detach XC_Integrated550_560_v1_1_RBpDX_FD44_v4.dmg" do
    command "hdiutil detach \"/Volumes/User Software\""
    user node['current_user']
    only_if "mount | grep -q 'User Software'"
end

