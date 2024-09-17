#!/bin/bash

# Temp file for storing tshark output
temp_file="temp.txt"

# Extracting time and Signal Strength
tshark -r "$1" -T fields -e frame.time_relative -e frame.number > "$temp_file"

# Calculating average Signal Strength and time 
awk '{
    t = $1   # Time as floating-point number
    num = $2 # Packet count as integer

    if (t <= prev_t) {
        total_num += num
    } else {
        if (prev_t != 0) {
            if (count != 0) {
                avg_num = total_num / count
                print prev_t, avg_num
            } else {
                print prev_t, 0
            }
        }
        prev_t = t + 60
        total_num = num
        count = 0
    }
    count++
}
END {
    if (prev_t != 0) {
        if (count != 0) {
            avg_num = total_num / count
            print prev_t, avg_num
        } else {
            print prev_t, 0
        }
    }
}' prev_t=0 total_num=0 count=0 "$temp_file" > "average_num.txt"

# Plotting GNUPlot
gnu_p="gnu_p.gnu"

echo "set terminal png size 1000,800" > "$gnu_p"
echo "set output 'avg_packet_rate_time.png'" >> "$gnu_p"
echo "set title 'Average Number of Packet vs Time'" >> "$gnu_p"
echo "set xlabel 'Time'" >> "$gnu_p"
echo "set ylabel 'Avg Packet'" >> "$gnu_p"
echo "set xdata time" >> "$gnu_p"
echo "set timefmt '%s'" >> "$gnu_p"
echo "set format x '%H:%M:%S'" >> "$gnu_p"
echo "plot 'average_num.txt' using 1:2 with linespoints title 'Avg Number of Packet vs Time'" >> "$gnu_p"

# Running gnuplot script
gnuplot "$gnu_p"

# Removing all temp files
rm "$temp_file" "$gnu_p" "average_num.txt"

echo "Successful!"

