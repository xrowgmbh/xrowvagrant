# Patch Management

## Patch convention
Patch format convention: Unified diff (diff -u)

Patch author numbering:

1xx eZ Publish Professional Service Support
2xx eZ Publish Support (Service Packs, Tickets)
3xx eZ Partner XROW patches
4xx Client's patches
5xx Patches from other Parties

Patch naming convention: 
( author number + patch number ) + "_" +  ( ticket number or short description ).diff

e.g.:
patches/202_batch-move-EZP-121243.diff

## Patch Documentation convention
Every patch may be documented along the belonging patch file, if needed. The file name is exactly matching the pach files name

e.g.:
patches/202_batch-move-EZP-121243.txt

patch documentation specifications:
--------------------------------------------------------------------------------
- short name / name of the developer who has created the patch
- Short description, the purpos of the patch
- ticket number (optional)

## Patch directory structure convention

Patches which are part of future versions of eZ Publish should be stored in 
directories named by the version number, eg. 5.2
Other Patches need to be stored in the root of the folder.

e.g.:
patches/5.2/101_servicepack-EZP1.diff
patches/202_batch-move-EZP-121243.diff
patches/202_batch-move-EZP-121243.txt
