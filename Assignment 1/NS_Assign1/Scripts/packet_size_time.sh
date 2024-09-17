#!/bin/bash

# Temp file for storing tshark output
temp_file="temp.txt"

# Extracting time and frame size
tshark -r "$1" -T fields -e frame.time_relative -e frame.len > "$temp_file"

# Calculating average packet size and time 
awk '{
    t = int($1)
    size = int($2)

    if (t <= prev_t) {
        total_size += size
        count++
    } else {
        if (prev_t != 0) {
            avg_size = total_size / count
            print prev_t, avg_size
        }
        prev_t = t+60
        total_size = size
        count = 1
    }
}
END {
    if (prev_t != 0) {
        avg_size = total_size / count
        print prev_t, avg_size
    }
}' prev_t=0 total_size=0 count=0 "$temp_file" > "average_data.txt"


#Plotting GNUPlot
gnu_p="gnu_p.gnu"

echo "set terminal png size 1000,800" > "$gnu_p"
echo "set output 'avg_packet_size_time.png'" >> "$gnu_p"
echo "set title 'Average Packet Size vs Time'" >> "$gnu_p"
echo "set xlabel 'Time'" >> "$gnu_p"
echo "set ylabel 'Avg Packet Size'" >> "$gnu_p"
echo "set xdata time" >> "$gnu_p"
echo "set timefmt '%s'" >> "$gnu_p"
echo "set format x '%H:%M:%S'" >> "$gnu_p"
echo "plot 'average_data.txt' using 1:2 with linespoints title 'Avg Packet Size vs Time'" >> "$gnu_p"

#Running gnuplot script
gnuplot "$gnu_p"

# Removing all temp files
rm "$temp_file" "$gnu_p" "average_data.txt"

echo "Successfull!"

