#!/bin/bash

# convert zipped application to DMG for Munki/distribution

# (C)2017 Peter Kelm
# All rights reserved

# check arguments
if [ "$#" -ne 2 ] || ! [ -f "$1" ] || ! [ -d "$2" ]; then
  echo "Usage: $0 ZIPFILE OUTPUTDIR" >&2
  exit 1
fi

# drop out if $1 is not a zip file
if [[ `zipinfo -h "$1" 2>&1` != "Archive: "* ]]; then
  echo "$1 is not a zip file! Aborting." >&2
  exit 1
fi

# extract base name
BASENAME=$(basename "$1" .zip)

# create temp directory
OUTDIR=$(mktemp -d "${TMPDIR:-/tmp/}${BASENAME}.XXXXXXXXXXXX")

if [ -z "$OUTDIR" ] || ! [ -d "$OUTDIR" ]; then
  echo "cannot create temporary directory: ${OUTDIR}. Aborting." >&2
  exit 1
fi

# expand zip --- note that unzip can't handle this!
ditto -xk "$1" "$OUTDIR"

# create dmg from directory
hdiutil create -srcfolder "$OUTDIR" "${2}/${BASENAME}.dmg"

# cleanup
rm -rf "$OUTDIR"

# success
exit 0