#!/bin/bash

# Output filename for storing tshark results
management_file="management.txt"
control_file="controls.txt"
data_file="datas.txt"

#Management Frames
mgmt=("Authentication" "Deauthentication" "Association_request" "Association_response" "Probe_request" "Probe_response" "Probe")
mgmt_v=("0x000b" "0x000c" "0x0000" "0x0001" "0x0004" "0x0005" "0x0008")

m_flag=1
c_flag=1
d_flag=1


for ((i=0; i<${#mgmt[@]}; i++)); do
    name="${mgmt[$i]}"
    value="${mgmt_v[$i]}"
    
    line_count=$(tshark -r "$1" -Y "wlan.fc.type_subtype == $value" | wc -l )
    echo "$name $line_count" >> "$management_file"
    if [ "$line_count" -eq 0 ]; then 
    	m_flag=0
    fi
done

#Control 

control=("RTS" "CTS" "ACK" "Block_ACK")
control_v=("0x001b" "0x001c" "0x0019" "0x001d")


for ((i=0; i<${#control[@]}; i++)); do
    name="${control[$i]}"
    value="${control_v[$i]}"
    
    line_count=$(tshark -r "$1" -Y "wlan.fc.type_subtype == $value" | wc -l )
    echo "$name $line_count" >> "$control_file"
    if [ "$line_count" -eq 0 ]; then 
    	c_flag=0
    fi
done


#Data

data=("QoS_Data" "Null_Function" "Data")
data_v=("0x0028" "0x0024" "0x0020")


for ((i=0; i<${#data[@]}; i++)); do
    name="${data[$i]}"
    value="${data_v[$i]}"
    
    line_count=$(tshark -r "$1" -Y "wlan.fc.type_subtype == $value"| wc -l )
    echo "$name $line_count" >> "$data_file"
    if [ "$line_count" -eq 0 ]; then 
    	d_flag=0
    fi
done

