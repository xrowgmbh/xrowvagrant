#!/bin/sh
PWD=$(pwd)
rm -Rf ezpublish_legacy/settings/override ezpublish_legacy/settings/siteaccess ezpublish_legacy/var/ezdemo_site/log ezpublish_legacy/var/ezdemo_site/cache
wget --no-check-certificate -O dump.tgz https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/demo/dump.tgz
tar --no-same-permissions -xzvf dump.tgz
rm -Rf ezpublish_legacy/var/ezdemo_site/log/ ezpublish_legacy/var/ezdemo_site/cache/
mysql -uroot -e'create database ezpublish'
mysql -uroot ezpublish < ezpublish_legacy/var/ezdemo_site/dump.sql
rm -Rf dump.tgz
php ezpublish/console ezpublish:legacy:script bin/php/ezpgenerateautoloads.php
source ./fixpermissions.sh