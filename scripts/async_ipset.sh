#!/bin/sh
DEST_DIR=$1
ONAME=`echo $2 | md5sum | cut -d ' ' -f 1`
outf="$DEST_DIR/$ONAME.tmp"
wget -q $2 -O $outf
if [ $? -ne 0 ]; then
    echo "Failed to update ipset from $2"
    ipset restore < $outf
    echo "Successfully loaded ipset from backup $outf"
else
    sed -i "s/^/add ${3} /" $outf
    echo "Successfully loaded ipset from $2"
fi
