#!/bin/sh

set -e
set -x

if [ ! -d ./web ]; then
  mkdir ./web
fi
cat <<EOL > ./web/.htaccess
RewriteEngine On
RewriteRule .* error.php?error=503
EOL

cat <<EOL > ./web/error.php
<?php
if ( !isset( \$_GET['error'] ) ){ \$_GET['error'] = 503; }
header('HTTP/1.1 '.\$_GET['error'].' Service Temporarily Unavailable');
header('Retry-After: 600');
echo \$_GET['error'] . " Building try later.";
exit();
EOL

COMPOSER_NO_INTERACTION=1
wget -O ezpublish5.tar.gz --no-check-certificate "http://packages.xrow.com/software/5.4/ezpublish5-5.4.0-ee-bul-full.tar.gz"
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
        s|^RemotePackagesIndexURL[[:blank:]]*=.*|RemotePackagesIndexURL=http:\/\/packages.ez.no\/ezpublish\/5.4\/5.4.0\/|
}" ezpublish_legacy/settings/package.ini

find {ezpublish/{cache,logs,config,sessions},ezpublish_legacy/{design,extension,settings,var},web} -type d | xargs chmod -R 777
find {ezpublish/{cache,logs,config,sessions},ezpublish_legacy/{design,extension,settings,var},web} -type f | xargs chmod -R 666

cat <<EOL > ./auth.json
{
    "http-basic": {
        "updates.ez.no": {
            "username": "${INSTALLATION_ID}",
            "password": "${LICENCE_KEY}"
        }
    }
}
EOL
composer -n update
composer -n require --prefer-dist ezsystems/ezfind-ls:${VERSION}.*
composer -n require --prefer-dist ezsystems/eztags-ls
#composer -n require ezsystems/platform-ui-bundle:dev-master
#composer -n require xrow/ezpublish-solrdocs-bundle:dev-master

chmod 755 ezpublish/console
ezpublish/console -n assets:install --symlink --relative web
ezpublish/console -n ezpublish:legacy:assets_install --symlink --relative web
# ether
ezpublish/console -n assetic:dump --env=prod
# or
#ezpublish/console -n assetic:dump --env=dev
composer -n dump-autoload --optimize

wget --no-check-certificate -O web/robots.txt https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/robots.txt
wget --no-check-certificate -O web/.htaccess https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/.htaccess

cp -a /usr/share/ezcluster/bin/tools/* .
source ./insertdemo.sh
source ./cache.sh