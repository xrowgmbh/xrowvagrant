# Patch Management

## Patch file convention

Patch format convention: Unified diff (diff -u) with relative paths from the symfony root dir.

e.g.:
```
Index: vendor/ezsystems/ezpublish-kernel/eZ/Bundle/EzPublishLegacyBundle/Controller/LegacyKernelController.php
===================================================================
--- vendor/ezsystems/ezpublish-kernel/eZ/Bundle/EzPublishLegacyBundle/Controller/LegacyKernelController.php	(Revision 19123)
+++ vendor/ezsystems/ezpublish-kernel/eZ/Bundle/EzPublishLegacyBundle/Controller/LegacyKernelController.php	(Arbeitskopie)
@@ -166,6 +166,9 @@
                 case "expires":
                     $response->setExpires( new DateTime( $headerValue ) );
                     break;
+                case "set-cookie":
+                    $response->headers->set( $headerName, $headerValue, false );
+                    break;
                 default;
                     $response->headers->set( $headerName, $headerValue, true );
                     break;
```

Patch author numbering:

* 1xx eZ Publish Professional Service Support
* 2xx eZ Publish Support (Service Packs, Tickets)
* 3xx eZ Partner XROW patches
* 4xx Client's patches
* 5xx Patches from other Parties

Patch naming convention: 
( author number + patch number ) + "_" +  ( ticket number or short description ).diff

e.g.:
```
patches/202_batch-move-EZP-121243.diff
```

## Patch documentation convention
Every patch may be documented along the belonging patch file, if needed. The file name is exactly matching the pach files name

e.g.:
```
patches/202_batch-move-EZP-121243.txt
```

The patch documentation should include:

- Short name / name of the developer who has created the patch
- Short description, the purpos of the patch
- Ticket number (optional)

## Patch directory structure convention

Patches which are part of future versions of eZ Publish should be stored in 
directories named by the version number, eg. 5.2
Other Patches need to be stored in the root of the folder.

e.g.:
```
patches/5.2/101_servicepack-EZP1.diff
patches/202_batch-move-EZP-121243.diff
patches/202_batch-move-EZP-121243.txt
```
