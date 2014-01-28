@echo off

CALL vagrant destroy --force >> vagrant.log
CALL rmdir /S /Q .vagrant
CALL rmdir /S /Q %USERPROFILE%\.vagrant.d\boxes\centos64
CALL vagrant up >> vagrant.log
CALL vagrant reload up >> vagrant.log
CALL vagrant plugin install --plugin-source https://rubygems.org --plugin-prerelease vagrant-vbguest >> vagrant.log
CALL vagrant vbguest --do rebuild >> vagrant.log
CALL vagrant reload >> vagrant.log
CALL vagrant ssh-config >> vagrant.log
rem get contents .vagrant\machines\centos64\virtualbox\id   is 1325059c-dd53-41ab-b2d0-2cd2b002493d
rem CALL vagrant package --base 1325059c-dd53-41ab-b2d0-2cd2b002493d --output ezpublish.box --vagrantfile Vagrantfile.dist
pause