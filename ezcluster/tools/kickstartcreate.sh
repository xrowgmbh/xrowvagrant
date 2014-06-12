#!/bin/sh
PWD=$(pwd)

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
Database=ezpublish
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
Database=ezpublish
DatabaseAction=remove

[site_details]
Continue=true
Title=New site
Access=ezdemo_site
AdminAccess=ezdemo_site_admin
AccessPort=80
AccessHostname=localhost
AdminAccessHostname=localhost
Database=ezpublish
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