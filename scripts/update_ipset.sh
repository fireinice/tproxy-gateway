#!/bin/sh
DEST_IPSET=$@
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
    elif echo "$1" | grep -q "http"; then
	wget -q $1 -O $outf
    else
	return
    fi
    sed "s/^/add ${2} /" $outf >> $DEST_IPSET
    rm $outf
}

echo -n "Generating ipset..."
gen_ips_multi $DEST_V4 bypass_dest
gen_ips_multi $DEST_V6 bypass_dest_v6
gen_ips_multi $SOURCE_V4 bypass_source
gen_ips_multi $SOURCE_V6 bypass_source_v6
gen_ips_multi $MAC_SRC_V4 bypass_mac_src
gen_ips_multi $MAC_SRC_V6 bypass_mac_src_v6
echo "done"

echo -n "Restore ipset..."
ipset restore < $DEST_IPSET
echo "done"
