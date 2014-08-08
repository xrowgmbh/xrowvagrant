#!/bin/sh
PWD=$(pwd)
rm -Rf ezpublish_legacy/settings/override ezpublish_legacy/settings/siteaccess ezpublish_legacy/var/ezdemo_site/log ezpublish_legacy/var/ezdemo_site/cache
wget --no-check-certificate -O dump.zip https://github.com/xrowgmbh/xrowvagrant-demodata/archive/master.zip
unzip -o -d $PWD dump.zip
rm -Rf ezpublish_legacy/var/ezdemo_site/log/ ezpublish_legacy/var/ezdemo_site/cache/
mysql -uroot -e'create database ezpublish'
mysql -uroot ezpublish < ezpublish_legacy/var/ezdemo_site/dump.sql
rm -Rf dump.zip
php ezpublish/console ezpublish:legacy:script bin/php/ezpgenerateautoloads.php
source ./fixpermissions.sh
# Bug https://project.issues.ez.no/IssueView.php?Id=12514&activeItem=1
echo "For solr indexing run:"
echo "php ezpublish/console ezpublish:legacy:script --env=dev -n extension/ezfind/bin/php/updatesearchindexsolr.php"