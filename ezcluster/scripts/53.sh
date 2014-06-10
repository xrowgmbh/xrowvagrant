#!/bin/sh

wget -O ezpublish5.tar.gz --no-check-certificate "http://packages.xrow.com/software/5.3/ezpublish5-5.3.0-ee-ttl-full.tar.gz"
tar --strip-components=1 -xzf ezpublish5.tar.gz
rm -Rf ezpublish5.tar.gz

# OLD
mkdir -p ezpublish_legacy/extension/ezfind
cd ezpublish_legacy/extension/ezfind
wget -O ezfind.tar.gz "http://packages.xrow.com/software/5.3/ezfind-5.3.0.tar.gz"
tar --strip-components=1 -xzf ezfind.tar.gz
rm -Rf ezfind.tar.gz
cd ..
cd ..
cd ..
#New but buggy https://project.issues.ez.no/IssueView.php?Id=12462
#composer require --prefer-dist ezsystems/ezfind-ls:5.3.*

sed -i "s/CURLOPT_CONNECTTIMEOUT, 3/CURLOPT_CONNECTTIMEOUT, 10/g" ezpublish_legacy/kernel/setup/steps/ezstep_site_types.php
sed -i "s/\/\/umask(/umask(/g" ezpublish/console
sed -i "s/\/\/umask(/umask(/g" web/index_dev.php
sed -i '/<?php/ a\
umask(0000);' web/index.php

find {ezpublish/{cache,logs,config},ezpublish_legacy/{design,extension,settings,var},web} -type d | xargs chmod -R 777
find {ezpublish/{cache,logs,config},ezpublish_legacy/{design,extension,settings,var},web} -type f | xargs chmod -R 666
php -r "eval('?>'.file_get_contents('https://getcomposer.org/installer'));"
composer require xrow/ezpublish-tools-bundle:@dev

php ezpublish/console assets:install --symlink web
php ezpublish/console ezpublish:legacy:assets_install --symlink web
php ezpublish/console assetic:dump web
php ezpublish/console assetic:dump --env=prod web
composer dump-autoload --optimize

wget --no-check-certificate -O web/robots.txt https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/robots.txt
wget --no-check-certificate -O web/.htaccess https://raw.github.com/xrowgmbh/xrowvagrant/master/ezcluster/templates/.htaccess

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
Database=xrow52
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
Database=xrow52
DatabaseAction=remove

[site_details]
Continue=true
Title=New site
Access=site
AdminAccess=site_admin
AccessPort=8080
AccessHostname=localhost
AdminAccessHostname=localhost
Database=xrow52
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