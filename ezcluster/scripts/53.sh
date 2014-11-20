#!/bin/sh

wget -O ezpublish5.tar.gz --no-check-certificate "http://packages.xrow.com/software/5.3/ezpublish5-5.3.0-ee-bul-full.tar.gz"
tar --strip-components=1 -xzf ezpublish5.tar.gz
rm -Rf ezpublish5.tar.gz

sed -i "s/CURLOPT_CONNECTTIMEOUT, 3/CURLOPT_CONNECTTIMEOUT, 10/g" ezpublish_legacy/kernel/setup/steps/ezstep_site_types.php
sed -i "s/\/\/umask(/umask(/g" ezpublish/console
sed -i '/<?php/ a\
umask(0000);' web/index.php
# no clue!
#sed -i "/^\[RepositorySettings\]/,/^\[/ {
#        s|^#\?RemotePackagesIndexURL[[:blank:]]*=.*|RemotePackagesIndexURL="${PACKAGES}"|
#}" ezpublish_legacy/settings/package.ini

sed -i "/^\[RepositorySettings\]/,/^\[/ {
        s|^RemotePackagesIndexURL[[:blank:]]*=.*|RemotePackagesIndexURL=http:\/\/packages.ez.no\/ezpublish\/5.3\/5.3.0\/|
}" ezpublish_legacy/settings/package.ini

find {ezpublish/{cache,logs,config,sessions},ezpublish_legacy/{design,extension,settings,var},web} -type d | xargs chmod -R 777
find {ezpublish/{cache,logs,config,sessions},ezpublish_legacy/{design,extension,settings,var},web} -type f | xargs chmod -R 666
rm -f composer.json
rm -f composer.lock
wget --no-check-certificate -O composer.json https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/5.3/composer.json

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
#composer require ezsystems/platform-ui-bundle:dev-master
#composer require xrow/ezpublish-solrdocs-bundle:dev-master

php ezpublish/console assets:install --symlink --relative web
php ezpublish/console ezpublish:legacy:assets_install --symlink --relative web
php ezpublish/console assetic:dump --env=prod web
composer dump-autoload --optimize

wget --no-check-certificate -O web/robots.txt https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/robots.txt
wget --no-check-certificate -O web/.htaccess https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/.htaccess

# overwrite because path is absolute in index_cluster.php
rm -f web/index_cluter.php
wget --no-check-certificate -O web/index_cluster.php https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/index_cluster.php
rm -f web/index_rest.php
wget --no-check-certificate -O web/index_rest.php https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/index_rest.php

cp -a /usr/share/ezcluster/bin/tools/* .
source ./insertdemo.sh
source ./cache.sh