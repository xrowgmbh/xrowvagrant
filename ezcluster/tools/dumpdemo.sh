#!/bin/sh
PWD=$(pwd)
mysqldump -n --default-character-set=utf8 --opt --single-transaction -hlocalhost -uroot ezpublish > ezpublish_legacy/var/dump.sql
sudo tar -czf dump.tar.gz -C $PWD ./ezpublish_legacy/settings/override ./ezpublish_legacy/settings/siteaccess/ ./ezpublish_legacy/var/ ./ezpublish/config/