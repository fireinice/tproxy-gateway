#!/bin/sh
DEST_DIR=$1
ONAME=`echo $2 | md5sum | cut -d ' ' -f 1`
outf="$DEST_DIR/$ONAME.tmp"
counter=0
while [ $counter -lt 10 ]
do
    wget -q $2 -O $outf
    if [ $? -eq 0 ]; then
	sed -i "s/^/add ${3} /" $outf
	echo "Successfully update ipset from $2"
	counter=10
    else
	echo "failed update ipset from $2, retrying.. ${counter} times"
    fi
    if [ $counter -eq 10 ]; then
	ipset restore < $outf
	echo "Successfully loaded ipset from $2"
    elif [ $counter -ge 4 ]; then
	ipset restore < $outf
	echo "Successfully loaded ipset from backup"
    fi
    sleep 30
    counter=$((counter + 1))
done
