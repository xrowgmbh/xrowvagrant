#!/bin/sh
PWD=$(pwd)
rm -Rf ezpublish_legacy/settings/override ezpublish_legacy/settings/siteaccess ezpublish_legacy/var/ezdemo_site/log ezpublish_legacy/var/ezdemo_site/cache
wget --no-check-certificate -O dump.tgz https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/demo/dump.tgz
tar --no-same-permissions -xzvf dump-5.3.tgz
rm -Rf ezpublish_legacy/var/ezdemo_site/log/ ezpublish_legacy/var/ezdemo_site/cache/
mysql -e'create database ezpublish'
mysql ezpublish < ezpublish_legacy/var/ezdemo_site/dump.sql
rm -Rf dump-5.3.tgz
source ./fixpermissions.sh