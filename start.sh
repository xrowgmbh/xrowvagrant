#!/bin/sh

rm -Rf vagrant.log
vagrant destroy --force >> vagrant.log
rm -Rf .vagrant

vagrant up >> vagrant.log
vagrant plugin install --plugin-source https://rubygems.org vagrant-vbguest >> vagrant.log
vagrant reload >> vagrant.log
vagrant ssh-config >> vagrant.log