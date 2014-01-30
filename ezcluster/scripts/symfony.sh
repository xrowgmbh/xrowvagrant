#!/bin/sh
#export http_proxy=http://192.0.0.1:8080/
rm -Rf *
composer.phar -vvv create-project symfony/framework-standard-edition . 2.4.* --prefer-dist --no-interaction
cat <<EOL > app/config/parameters.yml
# This file is auto-generated during the composer install
parameters:
    database_driver: pdo_mysql
    database_host: 127.0.0.1
    database_port: null
    database_name: symfony
    database_user: root
    database_password: null
    mailer_transport: smtp
    mailer_host: 127.0.0.1
    mailer_user: null
    mailer_password: null
    locale: en
    secret: c60211546d9737d16d4a34e90fb9f7b1d69bacba
    database_path: null
EOL
rm composer.json
rm web/config.php
mv web/app.php web/index.php
mv web/app_dev.php web/index_dev.php
cp /etc/ezcluster/templates/index_dev.php web/index_dev.php
cp /etc/ezcluster/templates/composer.symfony.json composer.json
cp /etc/ezcluster/templates/AppKernel.php app/AppKernel.php
cp /etc/ezcluster/templates/routing_dev.yml app/config/routing_dev.yml
composer.phar -vvv install --no-interaction
composer.phar -vvv update --no-interaction
sed -i "s/\/\/umask(/umask(/g" app/console
sed -i "s/\/\/umask(/umask(/g" web/index_dev.php
sed -i "s/\/\/umask(/umask(/g" web/index.php
sed -i "s/app/index/g" web/.htaccess

find app/{cache,logs,config} -type d | sudo xargs chmod -R 777
find app/{cache,logs,config} -type f | sudo xargs chmod -R 666