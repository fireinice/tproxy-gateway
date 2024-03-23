#!/bin/sh
DEST_IPSET=$@
DEST_DIR=`dirname $DEST_IPSET`
gen_ips_multi() {
  parts=$(echo $1 | tr ";" "\n")

 for part in $parts
 do
     gen_ips $part $2
 done

}

gen_ips() {
    outf="$DEST_DIR/$2.tmp"
    touch $outf
    if [ -f "$1" ]; then
	cp $1 $outf
	sed "s/^/add ${2} /" $outf >> $DEST_IPSET
	rm $outf
    elif echo "$1" | grep -q "http"; then
	/scripts/async_ipset.sh $DEST_DIR $1 $2 &
    else
	return
    fi
}

echo -n "Generating ipset..."
gen_ips_multi $NET_DST_V4 bypass_dest
gen_ips_multi $NET_DST_V6 bypass_dest_v6
gen_ips_multi $NET_SRC_V4 bypass_source
gen_ips_multi $NET_SRC_V6 bypass_source_v6
gen_ips_multi $MAC_SRC_V4 bypass_mac_src
gen_ips_multi $MAC_SRC_V6 bypass_mac_src_v6
echo "done"

echo -n "Restore ipset..."
ipset restore < $DEST_IPSET
rm $DEST_IPSET
echo "done"
