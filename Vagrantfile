# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.define :centos64
    config.vm.box = "centos64"
    config.vm.provision :shell, :path => "bootstrap.sh"
    config.vm.boot_timeout = 1000
    config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box"

    config.ssh.forward_agent = true
	config.vm.network "public_network", bridge: 'en1: Wi-Fi (AirPort)'
    config.vm.network :forwarded_port, host: 80, guest: 80
    config.vm.network :forwarded_port, host: 8080, guest: 8080
    config.vm.network :forwarded_port, host: 443, guest: 443
    config.vm.network :forwarded_port, host: 3306, guest: 3306
    config.vm.network :forwarded_port, host: 8983, guest: 8983
    config.vm.network :forwarded_port, host: 9200, guest: 9200
    config.vm.network :forwarded_port, host: 9292, guest: 9292
# ZendDebugger Handled by port forwarding in the ssh connection
#   config.vm.network :forwarded_port, host: 10137, guest: 10137
#   config.vm.network :forwarded_port, host: 20080, guest: 20080
    private_key_path = "insecure_private_key"

    config.vm.synced_folder "ezcluster", "/etc/ezcluster"	
    config.vm.synced_folder "sites", "/var/www/sites", disabled: true, group: "ec2-user", owner: "ec2-user", create: true
#    config.ssh.username = "root"

    # Allow symlinks
#    config.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/cross-compiler", "1"]

    config.vm.provider "virtualbox" do |v|
        v.memory = 4096
        v.cpus = 2
    end
end