#!/bin/sh

wget http://download.revive-adserver.com/revive-adserver-3.0.2.tar.gz
tar --strip-components=1 -xzf revive-adserver-3.0.2.tar.gz
rm revive-adserver-3.0.2.tar.gz

chmod -R a+w var
chmod -R a+w var/cache
chmod -R a+w var/plugins
chmod -R a+w var/templates_compiled
chmod -R a+w plugins
chmod -R a+w www/admin/plugins
chmod -R a+w www/images