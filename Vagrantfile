# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "quantal64"
  config.vm.box_url = "https://s3-eu-west-1.amazonaws.com/kunstmaan-vagrant/quantal64.box"
  config.ssh.forward_agent = true
  config.vm.boot_mode :gui
  config.vm.network :hostonly, "33.33.33.33"
  config.vm.share_folder("kitchenplan", "/opt/kitchenplan", ".", :nfs => true, :extra => 'dmode=777,fmode=777')
end
