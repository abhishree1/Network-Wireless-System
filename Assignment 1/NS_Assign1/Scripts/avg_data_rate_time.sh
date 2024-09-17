#!/bin/bash

# Temp file for storing tshark output
temp_file="temp.txt"

# Extracting time and data rate
tshark -r "$1" -T fields -e frame.time_relative -e radiotap.datarate > "$temp_file"

# Calculating average data rate and time 
awk '{
    t = int($1)
    rate = int($2)

    if (t <= prev_t) {
        total_rate += rate
        count++
    } else {
        if (prev_t != 0) {
            avg_rate = total_rate / count
            print prev_t, avg_rate
        }
        prev_t = t+60
        total_rate = rate
        count = 1
    }
}
END {
    if (prev_t != 0) {
        avg_rate = total_rate / count
        print prev_t, avg_rate
    }
}' prev_t=0 total_rate=0 count=0 "$temp_file" > "average_rate.txt"


#Plotting GNUPlot
gnu_p="gnu_p.gnu"

echo "set terminal png size 1000,800" > "$gnu_p"
echo "set output 'avg_data_rate_time.png'" >> "$gnu_p"
echo "set title 'Average Data Rate vs Time'" >> "$gnu_p"
echo "set xlabel 'Time'" >> "$gnu_p"
echo "set ylabel 'Avg Data Rate'" >> "$gnu_p"
echo "set xdata time" >> "$gnu_p"
echo "set timefmt '%s'" >> "$gnu_p"
echo "set format x '%H:%M:%S'" >> "$gnu_p"
echo "plot 'average_rate.txt' using 1:2 with linespoints title 'Avg Data Rate vs Time'" >> "$gnu_p"

gnuplot "$gnu_p"

# Removing all temp files
rm "$temp_file" "$gnu_p" "average_rate.txt"

echo "Successfull!"

