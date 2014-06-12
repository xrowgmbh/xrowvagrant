#!/bin/sh
PWD=$(pwd)

source ./cache.sh
rm -Rf ezpublish_legacy/var/log/*
rm -Rf ezpublish/logs/*
rm -Rf ezpublish_legacy/var/ezdemo_site/log/*
rm -Rf ezpublish_legacy/var/storage/packages/*
rm -Rf ezpublish_legacy/settings/override/*.php~
rm -Rf ezpublish_legacy/settings/siteaccess/*/*.php~
rm -Rf ezpublish_legacy/settings/siteaccess/{plain,admin,mysite,base}
rm -Rf web/var/log/*

