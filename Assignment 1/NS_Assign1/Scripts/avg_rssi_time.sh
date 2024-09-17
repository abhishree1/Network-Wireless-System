#!/bin/bash

# Temp file for storing tshark output
temp_file="temp.txt"

# Extracting time and Signal Strength
tshark -r "$1" -T fields -e frame.time_relative -e wlan_radio.signal_dbm > "$temp_file"

# Calculating average Signal Strength and time 
awk '{
    t = int($1)
    rssi = int($2)

    if (t <= prev_t) {
        total_rssi += rssi
        count++
    } else {
        if (prev_t != 0) {
            avg_rssi = total_rssi/ count
            print prev_t, avg_rssi
        }
        prev_t = t+60
        total_rssi =rssi
        count = 1
    }
}
END {
    if (prev_t != 0) {
        avg_rssi = total_rssi / count
        print prev_t, avg_rssi
    }
}' prev_t=0 total_rssi=0 count=0 "$temp_file" > "average_rssi.txt"


#Plotting GNUPlot
gnu_p="gnu_p.gnu"

echo "set terminal png size 1000,800" > "$gnu_p"
echo "set output 'avg_rssi_time.png'" >> "$gnu_p"
echo "set title 'Average RSSI vs Time'" >> "$gnu_p"
echo "set xlabel 'Time'" >> "$gnu_p"
echo "set ylabel 'Avg Data RSSI'" >> "$gnu_p"
echo "set xdata time" >> "$gnu_p"
echo "set timefmt '%s'" >> "$gnu_p"
echo "set format x '%H:%M:%S'" >> "$gnu_p"
echo "plot 'average_rssi.txt' using 1:2 with linespoints title 'Avg RSSI vs Time'" >> "$gnu_p"

#Running gnuplot script
gnuplot "$gnu_p"

# Removing all temp files
rm "$temp_file" "$gnu_p" "average_rssi.txt"

echo "Successfull!"

