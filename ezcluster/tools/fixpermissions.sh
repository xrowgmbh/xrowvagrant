#!/bin/sh
PWD=$(pwd)

find {ezpublish/{cache,logs,config,sessions},ezpublish_legacy/{design,extension,settings,var},web} -type d | xargs chmod -R 777
find {ezpublish/{cache,logs,config,sessions},ezpublish_legacy/{design,extension,settings,var},web} -type f | xargs chmod -R 666