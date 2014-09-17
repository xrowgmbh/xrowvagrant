<?php
/**
 * File containing the wrapper around the legacy index_rest.php file
 *
 * @copyright Copyright (C) eZ Systems AS. All rights reserved.
 * @license For full copyright and license information view LICENSE file distributed with this source code.
 */
$legacyRoot = '../ezpublish/../ezpublish_legacy';
chdir( $legacyRoot );
require $legacyRoot . '/index_rest.php';

