#!/bin/sh

rm -Rf * .git .gitignore .travis.yml
git clone --depth 1 https://github.com/ezsystems/ezpublish-community.git .
git clone --depth 1 https://github.com/ezsystems/ezpublish-legacy.git ezpublish_legacy
git clone --depth 1 https://github.com/ezsystems/ezfind ezpublish_legacy/extension/ezfind

#git clone https://github.com/xrowgmbh/xrowformgenerator ezpublish_legacy/extension/xrowformgenerator
#git clone https://github.com/xrowgmbh/xrowvideo ezpublish_legacy/extension/xrowvideo
#git clone https://github.com/xrowgmbh/xrowworkflow ezpublish_legacy/extension/xrowworkflow
#git clone https://github.com/xrowgmbh/xrowsass ezpublish_legacy/extension/xrowsass
#git clone https://github.com/xrowgmbh/xrowgis ezpublish_legacy/extension/xrowgis
#git clone https://github.com/xrowgmbh/xrowsearch ezpublish_legacy/extension/xrowsearch
#git clone https://github.com/xrowgmbh/xrowmetadata ezpublish_legacy/extension/xrowmetadata
#git clone https://github.com/xrowgmbh/xrowmetadata ezpublish_legacy/extension/xrowmetadata

sed -i "/^\[RepositorySettings\]/,/^\[/ {
        s|^RemotePackagesIndexURL[[:blank:]]*=.*|RemotePackagesIndexURL=http:\/\/packages.ez.no\/ezpublish\/5.3\/5.3.0\/|
}" ezpublish_legacy/settings/package.ini


sed -i "s/CURLOPT_CONNECTTIMEOUT, 3/CURLOPT_CONNECTTIMEOUT, 10/g" ezpublish_legacy/kernel/setup/steps/ezstep_site_types.php
sed -i "s/\/\/umask(/umask(/g" ezpublish/console
sed -i '/<?php/ a\
umask(0000);' web/index.php

find {ezpublish/{cache,logs,config,sessions},ezpublish_legacy/{design,extension,settings,var},web} -type d | xargs chmod -R 777
find {ezpublish/{cache,logs,config,sessions},ezpublish_legacy/{design,extension,settings,var},web} -type f | xargs chmod -R 666

RANDOM=´openssl rand -base64 32´
cat <<EOL > ./ezpublish/config/parameters.yml
# This file is auto-generated during the composer install
parameters:
    secret: $RANDOM
    locale_fallback: en
    ezpublish_legacy.default.view_default_layout: 'eZDemoBundle::pagelayout.html.twig'
EOL

composer require ezsystems/platform-ui-bundle:dev-master

#composer update
#php vendor/sensio/distribution-bundle/Sensio/Bundle/DistributionBundle/Resources/bin/build_bootstrap.php ezpublish

php ezpublish/console assets:install --symlink --relative web
php ezpublish/console ezpublish:legacy:assets_install --symlink web
php ezpublish/console --env=prod assetic:dump web

wget -O web/robots.txt http://s3-eu-west-1.amazonaws.com/xrow/downloads/ezcluster/robots.txt
wget -O web/.htaccess http://s3-eu-west-1.amazonaws.com/xrow/downloads/ezcluster/.htaccess

cp -a /etc/ezcluster/tools/* .
#source ./insertdemo.sh
source ./cache.sh