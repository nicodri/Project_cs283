#!/bin/bash

# specify here which version to use
BINFILE=vlfeat-0.9.20-bin.tar.gz

echo 'downloading vlfeat binaries...'
curl -O http://www.vlfeat.org/download/$BINFILE
echo 'unpacking binaries'
tar xf $BINFILE
BINFOLDER=${BINFILE%.*}
BINFOLDER=${BINFOLDER%.*}
BINFOLDER=${BINFOLDER%-*}
mv $BINFOLDER vlfeat/
rm $BINFILE
echo 'done!'