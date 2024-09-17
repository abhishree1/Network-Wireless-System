#!/bin/bash

# Temp file for storing tshark output
temp_file="temp.txt"

# Extracting packet size
tshark -r "$1" -T fields -e frame.len > "$temp_file"

# Plotting GNUPlot
gnu_p="gnu_p.gnu"

echo "set terminal png size 1000,800" > "$gnu_p"
echo "set output 'packet_size.png'" >> "$gnu_p"
echo "set title 'Packet Size'" >> "$gnu_p"
echo "set xlabel 'Packet Size'" >> "$gnu_p"
echo "set ylabel 'Count'" >> "$gnu_p"
echo "binwidth=10" >> "$gnu_p"
echo "b_wid(x,width)=width*floor(x/width)" >> "$gnu_p"
echo "plot '$temp_file' using (b_wid(\$1,binwidth)):(1) smooth freq with boxes notitle" >> "$gnu_p"

# Running gnuplot script
gnuplot "$gnu_p"

# Removing all temp files
rm "$temp_file" "$gnu_p"

echo "Successful!"

