#!/bin/sh
PWD=$(pwd)
rm -Rf ezpublish_legacy/settings/override ezpublish_legacy/settings/siteaccess ezpublish_legacy/var/ezdemo_site/log ezpublish_legacy/var/ezdemo_site/cache
wget http://packages.xrow.com/public/demo/dump-5.3.tgz
tar --no-same-permissions -xzvf dump-5.3.tgz
rm -Rf ezpublish_legacy/var/ezdemo_site/log ezpublish_legacy/var/ezdemo_site/cache
rm -Rf dump-5.3.tgz
source ./fixpermissions.sh