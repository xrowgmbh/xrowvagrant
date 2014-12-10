#!/bin/sh

COMPOSER_NO_INTERACTION=1
VERSION=5.4

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
        s|^RemotePackagesIndexURL[[:blank:]]*=.*|RemotePackagesIndexURL=http:\/\/packages.ez.no\/ezpublish\/$VERSION/$VERSION\.0\/|
}" ezpublish_legacy/settings/package.ini

sed -i "s/CURLOPT_CONNECTTIMEOUT, 3/CURLOPT_CONNECTTIMEOUT, 10/g" ezpublish_legacy/kernel/setup/steps/ezstep_site_types.php
sed -i "s/\/\/umask(/umask(/g" ezpublish/console
sed -i '/<?php/ a\
umask(0000);' web/index.php

find {ezpublish/{cache,logs,config,sessions},ezpublish_legacy/{design,extension,settings,var},web} -type d | xargs chmod -R 777
find {ezpublish/{cache,logs,config,sessions},ezpublish_legacy/{design,extension,settings,var},web} -type f | xargs chmod -R 666

RANDOM=´/usr/bin/openssl rand -base64 32´
cat <<EOL > ./ezpublish/config/parameters.yml
# This file is auto-generated during the composer install
parameters:
    secret: $RANDOM
    locale_fallback: en
    ezpublish_legacy.default.view_default_layout: 'eZDemoBundle::pagelayout.html.twig'
EOL

composer require ezsystems/platform-ui-bundle:dev-master
#cd vendor/ezsystems/platform-ui-bundle && bower -s install && cd -
#composer require xrow/ezpublish-tools-bundle:@dev
#composer require xrowgmbh/ezpublish-event-ls:dev-master
#composer require xrowgmbh/ezpublish-formgenerator-ls:dev-master
#composer require xrowgmbh/ezpublish-metadata-ls:dev-master
#composer require xrowgmbh/ezpublish-video-ls:dev-master
#composer require xrowgmbh/ezpublish-bigdata-bundle:dev-master

#composer update
#php vendor/sensio/distribution-bundle/Sensio/Bundle/DistributionBundle/Resources/bin/build_bootstrap.php ezpublish

chmod 755 ezpublish/console
ezpublish/console -n assets:install --symlink web
ezpublish/console -n ezpublish:legacy:assets_install --symlink web
ezpublish/console -n assetic:dump web
ezpublish/console -n assetic:dump --env=prod web
composer -n dump-autoload --optimize

wget --no-check-certificate -O web/robots.txt https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/robots.txt
wget --no-check-certificate -O web/.htaccess https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/.htaccess

cp -a /usr/share/ezcluster/bin/tools/* .
source ./insertdemo.sh
source ./cache.sh