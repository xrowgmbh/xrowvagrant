#!/bin/sh

cat <<EOL > ./index.php
<?php

echo "Start here: " . __FILE__echo "Start here: " . __FILE__;
exit(0);
EOL