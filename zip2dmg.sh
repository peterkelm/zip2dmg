#!/bin/bash

# convert zipped application to DMG for Munki/distribution

# (C) 2017 Peter Kelm

# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
hdiutil create -srcfolder "$OUTDIR" -volname "${BASENAME}" "${2}/${BASENAME}.dmg"

# cleanup
rm -rf "$OUTDIR"

# success
exit 0
