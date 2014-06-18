@echo off

CALL del vagrant.log
CALL vagrant destroy --force >> vagrant.log
CALL rmdir /S /Q .vagrant
rem CALL rmdir /S /Q %USERPROFILE%\.vagrant.d\boxes\centos64
CALL vagrant up >> vagrant.log
rem "C:\Program Files\Oracle\VirtualBox\vboxmanage" clonehd "C:\Users\bjoernd\VirtualBox VMs\centos65\centos65-disk1.vmdk" "C:\Users\bjoernd\VirtualBox VMs\centos65\centos65-disk1.vdi" --format vdi
rem "C:\Program Files\Oracle\VirtualBox\vboxmanage" modifyhd "C:\Users\bjoernd\VirtualBox VMs\centos65\centos65-disk1.vdi" --resize 30720
rem "C:\Program Files\Oracle\VirtualBox\vboxmanage" clonehd "C:\Users\bjoernd\VirtualBox VMs\centos65\centos65-disk1.vdi" "C:\Users\bjoernd\VirtualBox VMs\centos65\centos65-disk1.vmdk" --format vmdk
CALL vagrant plugin install --plugin-source https://rubygems.org vagrant-vbguest >> vagrant.log
CALL vagrant reload >> vagrant.log
CALL vagrant ssh-config >> vagrant.log
rem get contents .vagrant\machines\centos64\virtualbox\id   is 1325059c-dd53-41ab-b2d0-2cd2b002493d
rem CALL vagrant package --base 1325059c-dd53-41ab-b2d0-2cd2b002493d --output ezpublish.box --vagrantfile Vagrantfile.dist
pause