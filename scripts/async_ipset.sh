#!/bin/sh
DEST_DIR=$1
ONAME=`echo $2 | md5sum | cut -d ' ' -f 1`
outf="$DEST_DIR/$ONAME.tmp"
echo $outf
wget -q $2 -O $outf
sed -i "s/^/add ${3} /" $outf
ipset restore < $outf
rm $outf
echo "Successfully loaded ipset from $2"
