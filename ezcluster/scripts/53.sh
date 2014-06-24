#!/bin/sh

wget -O ezpublish5.tar.gz --no-check-certificate "http://packages.xrow.com/software/5.3/ezpublish5-5.3.0-ee-bul-full.tar.gz"
tar --strip-components=1 -xzf ezpublish5.tar.gz
rm -Rf ezpublish5.tar.gz

sed -i "s/CURLOPT_CONNECTTIMEOUT, 3/CURLOPT_CONNECTTIMEOUT, 10/g" ezpublish_legacy/kernel/setup/steps/ezstep_site_types.php
sed -i "s/\/\/umask(/umask(/g" ezpublish/console
sed -i "s/\/\/umask(/umask(/g" web/index_dev.php
sed -i '/<?php/ a\
umask(0000);' web/index.php
# no clue!
#sed -i "/^\[RepositorySettings\]/,/^\[/ {
#        s|^#\?RemotePackagesIndexURL[[:blank:]]*=.*$|RemotePackagesIndexURL="${PACKAGES}"|
#}" ezpublish_legacy/settings/package.ini

sed -i "/^\[RepositorySettings\]/,/^\[/ {
        s|^RemotePackagesIndexURL[[:blank:]]*=.*$|RemotePackagesIndexURL=http://packages.ez.no/ezpublish\/5.3\/5.3.0\/|
}" ezpublish_legacy/settings/package.ini

find {ezpublish/{cache,logs,config,sessions},ezpublish_legacy/{design,extension,settings,var},web} -type d | xargs chmod -R 777
find {ezpublish/{cache,logs,config,sessions},ezpublish_legacy/{design,extension,settings,var},web} -type f | xargs chmod -R 666
cat <<EOL > ./auth.json
{
    "config": {
        "basic-auth": {
            "updates.ez.no": {
                "username": "${INSTALLATION_ID}",
                "password": "${LICENCE_KEY}"
            }
        }
    }
}
EOL
composer update
composer require --prefer-dist ezsystems/ezfind-ls:5.3.*
#composer require xrow/ezpublish-tools-bundle:@dev



php ezpublish/console assets:install --symlink web
php ezpublish/console ezpublish:legacy:assets_install --symlink web
php ezpublish/console assetic:dump web
php ezpublish/console assetic:dump --env=prod web
composer dump-autoload --optimize

wget --no-check-certificate -O web/robots.txt https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/robots.txt
wget --no-check-certificate -O web/.htaccess https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/.htaccess

cp -a /etc/ezcluster/tools/* .
#source ./insertdemo.sh
source ./cache.sh