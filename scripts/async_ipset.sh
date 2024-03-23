#!/bin/sh
DEST_DIR=$1
ONAME=`echo $2 | md5sum | cut -d ' ' -f 1`
outf="$DEST_DIR/$ONAME.tmp"
wget -q $2 -O $outf
if [ $? -ne 0 ]; then
    echo "Failed to load ipset from $2"
    exit 1
fi
sed -i "s/^/add ${3} /" $outf
ipset restore < $outf
rm $outf
echo "Successfully loaded ipset from $2"
