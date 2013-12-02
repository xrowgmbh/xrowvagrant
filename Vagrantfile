# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.define :centos64
    config.vm.box = "centos64"
    config.vm.provision :shell, :path => "bootstrap.sh"

    config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210.box"

    config.ssh.forward_agent = true
    config.vbguest.auto_update = false
	config.vbguest.no_remote = true
    config.vm.network :forwarded_port, host: 80, guest: 80
    config.vm.network :forwarded_port, host: 8080, guest: 8080
    config.vm.network :forwarded_port, host: 443, guest: 443
#   config.vm.network :forwarded_port, host: 10137, guest: 10137
#   config.vm.network :forwarded_port, host: 20080, guest: 20080
    config.vm.synced_folder "C:\\workspace\\ezcluster", "/etc/ezcluster"
#    config.vm.synced_folder "C:\\workspace\\sites", "/var/www/sites"

    config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", "2048"]
    end
end
