#!/bin/sh
PWD=$(pwd)

rm -Rf ezpublish_legacy/var/cache/*
rm -Rf ezpublish/cache/*
rm -Rf ezpublish_legacy/var/ezdemo_site/cache/*
rm -Rf ezpublish_legacy/var/storage/packages/*
rm -Rf ezpublish_legacy/settings/override/*.php~
rm -Rf ezpublish_legacy/settings/siteaccess/*/*.php~
rm -Rf web/var/cache/*