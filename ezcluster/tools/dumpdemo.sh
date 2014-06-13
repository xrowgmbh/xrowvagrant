#!/bin/sh
PWD=$(pwd)
source ./cache.sh
mysqldump -n --default-character-set=utf8 --opt --single-transaction -hlocalhost -uroot ezpublish > ezpublish_legacy/var/ezdemo_site/dump.sql
sudo mkdir -p /etc/ezcluster/demo/
rm -Rf ezpublish_legacy/var/ezdemo_site/log/ ezpublish_legacy/var/ezdemo_site/cache/
sudo tar -czf /etc/ezcluster/demo/dump.tgz -C $PWD ./ezpublish_legacy/settings/override ./ezpublish_legacy/settings/siteaccess/ ./ezpublish_legacy/var/ezdemo_site ./ezpublish/config/