#!/bin/bash

min_clients=99999999
ssid=""
dump=$(sudo iw dev wlo1 scan)

#Searching for ssid with least station count
for s in "IITH IITH-GUEST OneP"; do
	count=$( echo "$dump"| grep -A 100 "SSID: $s" |grep "station count:"| cut -d' ' -f5)
        if [[ $count -lt $min_clients ]]; then
            min_clients=$count
            ssid="$s"
        fi
done

#disconnecting from current network
sudo iw dev wlo1 disconnect

#connecting to new network
if [[ $count == "IITH" ]]; then
        #mention password for iith
	sudo iw dev wlo1 connect -w "$ssid" shared 0:[mention password]
            
elif [[ $count == "IITH-GUEST" ]]; then
	#mention password for iith-guest
	sudo iw dev wlo1 connect -w "$ssid" shared 0:[mention password]
else
	#mention password for OneP
	sudo iw dev wlo1 connect -w "$ssid" shared 0:[mention password]
fi

