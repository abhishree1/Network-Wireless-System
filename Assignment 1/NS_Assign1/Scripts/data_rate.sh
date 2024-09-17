#!/bin/bash

# Temp file for storing tshark output
temp_file="temp.txt"

# Extracting data rate
tshark -r "$1" -T fields -e radiotap.datarate  > "$temp_file"

# Plotting GNUPlot
gnu_p="gnu_p.gnu"

echo "set terminal png size 1000,00" > "$gnu_p"
echo "set output 'data_rate.png'" >> "$gnu_p"
echo "set title 'Data Rate'" >> "$gnu_p"
echo "set xlabel 'Data Rate'" >> "$gnu_p"
echo "set ylabel 'Count'" >> "$gnu_p"
echo "binwidth=10" >> "$gnu_p"
echo "b_wid(x,width)=width*floor(x/width)" >> "$gnu_p"
echo "plot '$temp_file' using (b_wid(\$1,binwidth)):(1) smooth freq with boxes notitle" >> "$gnu_p"

# Running gnuplot script
gnuplot "$gnu_p"

# Removing all temp files
rm "$temp_file" "$gnu_p"

echo "Successful!"

