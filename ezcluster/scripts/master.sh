#!/bin/sh

rm -Rf *
git clone https://github.com/ezsystems/ezpublish-community.git .
git clone https://github.com/ezsystems/ezpublish-legacy.git ezpublish_legacy
git clone https://github.com/ezsystems/ezfind ezpublish_legacy/extension/ezfind

git clone https://github.com/xrowgmbh/xrowformgenerator ezpublish_legacy/extension/xrowformgenerator
git clone https://github.com/xrowgmbh/xrowvideo ezpublish_legacy/extension/xrowvideo
git clone https://github.com/xrowgmbh/xrowworkflow ezpublish_legacy/extension/xrowworkflow
git clone https://github.com/xrowgmbh/xrowsass ezpublish_legacy/extension/xrowsass
git clone https://github.com/xrowgmbh/xrowgis ezpublish_legacy/extension/xrowgis
git clone https://github.com/xrowgmbh/xrowsearch ezpublish_legacy/extension/xrowsearch
git clone https://github.com/xrowgmbh/xrowmetadata ezpublish_legacy/extension/xrowmetadata

sed -i "/^\[RepositorySettings\]/,/^\[/ {
	    s|^#\?RemotePackagesIndexURL[[:blank:]]*=.*$|RemotePackagesIndexURL=http://packages.ez.no/ezpublish/5.0/5.0.0|
	}" ezpublish_legacy/settings/package.ini

sed -i "s/CURLOPT_CONNECTTIMEOUT, 3/CURLOPT_CONNECTTIMEOUT, 10/g" ezpublish_legacy/kernel/setup/steps/ezstep_site_types.php

sed -i "s/\/\/umask(/umask(/g" ezpublish/console
sed -i '/<?php/ a\
umask(0000);' web/index.php

php -r "eval('?>'.file_get_contents('https://getcomposer.org/installer'));"
php composer.phar install --profile

wget https://raw.github.com/xrowgmbh/xrowvagrant/master/patches/201_install.diff
patch -p0 < 201_install.diff

cp ezpublish/config/ezpublish.yml.example ezpublish/config/ezpublish_prod.yml
sed -i "s/\/opt\/local\/bin\/convert/\/usr\/bin\/convert/g" ezpublish/config/ezpublish_prod.yml
sed -i "s/password: root/password:/g" ezpublish/config/ezpublish_prod.yml
sed -i "s/database_name: ezdemo/database_name: [DATABASE_NAME]/g" ezpublish/config/ezpublish_prod.yml
mysql -e'create database [DATABASE_NAME]'
cp ezpublish/config/parameters.yml.dist ezpublish/config/parameters.yml

mkdir -p ezpublish_legacy/var/storage && chmod 777 ezpublish_legacy/var/storage
cd ezpublish_legacy
php bin/php/ezpgenerateautoloads.php -e
cd ..
php ezpublish/console --env=prod ezpublish:legacy:script bin/php/ezpgenerateautoloads.php --extension 

find {ezpublish/{cache,logs,config},ezpublish_legacy/{design,extension,settings,var},web} -type d | sudo xargs chmod -R 777
find {ezpublish/{cache,logs,config},ezpublish_legacy/{design,extension,settings,var},web} -type f | sudo xargs chmod -R 666

php vendor/sensio/distribution-bundle/Sensio/Bundle/DistributionBundle/Resources/bin/build_bootstrap.php ezpublish

php ezpublish/console assets:install --symlink --relative web
php ezpublish/console ezpublish:legacy:assets_install --symlink web
php ezpublish/console --env=prod assetic:dump web

// FirePHP
// RPM
// 

wget -O web/robots.txt http://s3-eu-west-1.amazonaws.com/xrow/downloads/ezcluster/robots.txt
wget -O web/.htaccess http://s3-eu-west-1.amazonaws.com/xrow/downloads/ezcluster/.htaccess

rm -Rf ezpublish_legacy/var/cache/*
rm -Rf ezpublish_legacy/var/log/*
rm -Rf ezpublish/cache/*
rm -Rf ezpublish/log/*
cat <<EOL > ./reset.sh

rm -Rf ezpublish_legacy/var/cache/*
rm -Rf ezpublish_legacy/var/log/*
rm -Rf ezpublish_legacy/settings/override/*
rm -Rf ezpublish_legacy/settings/siteaccess/*
rm -Rf ezpublish/cache/*
rm -Rf ezpublish/logs/*
rm -Rf ezpublish_legacy/var/ezdemo_site/cache/*
rm -Rf ezpublish_legacy/var/ezdemo_site/log/*
rm -Rf web/var/cache/*
rm -Rf web/var/log/*
rm -Rf ezpublish/config/ezpublish.yml
rm -Rf ezpublish/config/ezpublish_dev.yml
rm -Rf ezpublish/config/ezpublish_prod.yml
mysql -e'drop database xrow52'
mysql -e'create database xrow52'

find {ezpublish/{cache,logs,config},ezpublish_legacy/{design,extension,settings,var},web} -type d | sudo xargs chmod -R 777
find {ezpublish/{cache,logs,config},ezpublish_legacy/{design,extension,settings,var},web} -type f | sudo xargs chmod -R 666

sudo /etc/init.d/httpd restart
sudo /etc/init.d/varnish restart
EOL

cat <<EOL > ./cache.sh
rm -Rf ezpublish_legacy/var/cache/*
rm -Rf ezpublish_legacy/var/log/*
rm -Rf ezpublish/cache/*
rm -Rf ezpublish/logs/*
rm -Rf ezpublish_legacy/var/ezdemo_site/cache/*
rm -Rf ezpublish_legacy/var/ezdemo_site/log/*
rm -Rf web/var/cache/*
rm -Rf web/var/log/*
sudo /etc/init.d/httpd restart
sudo /etc/init.d/varnish restart
EOL

cat <<EOL > ./ezpublish_legacy/kickstart.ini 
[email_settings]
Continue=true
Type=mta

[database_choice]
Continue=true
Type=mysqli

[database_init]
Continue=true
Server=localhost
Port=3306
Database={$DATABASE_NAME}
User=root

Password=
Socket=

[language_options]
Continue=true
Primary=eng-GB
#Languages[]=ger-DE
#Languages[]=fre-FR

[site_types]
Continue=true
Site_package=demo_site

[site_access]
Continue=true
Access=url

[site_details]
Continue=false
Database={$DATABASE_NAME}
DatabaseAction=remove

[site_details]
Continue=true
Title=New site
Access=site
AdminAccess=site_admin
AccessPort=8080
AccessHostname=localhost
AdminAccessHostname=localhost
Database={$DATABASE_NAME}
DatabaseAction=remove

[site_admin]
Continue=true
FirstName=God
LastName=Like
Email=nospam@ez.no
Password=publish

[security]
Continue=true

[registration]
Continue=true
Comments=
Send=false

EOL