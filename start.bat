@echo off

CALL vagrant destroy --force
CALL vagrant up centos64
CALL vagrant halt
rem get contents .vagrant\machines\centos64\virtualbox\id   is 1325059c-dd53-41ab-b2d0-2cd2b002493d
CALL vagrant package --base 1325059c-dd53-41ab-b2d0-2cd2b002493d --output ezpublish.box --vagrantfile Vagrantfile.dist
pause
rem qemu-img convert -O raw CloudBioLinux-32bit-disk1.vmdk CloudBioLinux-32bit-disk1.img
rem s3cmd put --acl-public --guess-mime-type biolinux_20110122.box s3://chapmanb/biolinux_20110122.box

