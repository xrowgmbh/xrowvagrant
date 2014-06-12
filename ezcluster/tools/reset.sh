#!/bin/sh
PWD=$(pwd)

source ./cache.sh
source ./clean.sh
rm -Rf ezpublish_legacy/settings/override/*
rm -Rf ezpublish_legacy/settings/siteaccess/*
rm -Rf ezpublish/config/ezpublish.yml
rm -Rf ezpublish/config/ezpublish_dev.yml
rm -Rf ezpublish/config/ezpublish_prod.yml
mysql -e'drop database ezpublish'
mysql -e'create database ezpublish'

find {ezpublish/{cache,logs,config,session},ezpublish_legacy/{design,extension,settings,var},web} -type d | sudo xargs chmod -R 777
find {ezpublish/{cache,logs,config,session},ezpublish_legacy/{design,extension,settings,var},web} -type f | sudo xargs chmod -R 666

sudo /etc/init.d/httpd restart
sudo /etc/init.d/varnish restart