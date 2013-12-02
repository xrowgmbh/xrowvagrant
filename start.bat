@echo off

CALL vagrant destroy
CALL rmdir /S /Q C:\Users\bjoernd\.vagrant.d\boxes\centos64
CALL vagrant up
rem 0.10 is not yet released so isntall from source https://github.com/dotless-de/vagrant-vbguest/issues/88
CALL vagrant plugin install --plugin-source https://rubygems.org --plugin-prerelease vagrant-vbguest
CALL vagrant halt
rem get contents .vagrant\machines\centos64\virtualbox\id   is 1325059c-dd53-41ab-b2d0-2cd2b002493d
rem CALL vagrant package --base 1325059c-dd53-41ab-b2d0-2cd2b002493d --output ezpublish.box --vagrantfile Vagrantfile.dist
pause

