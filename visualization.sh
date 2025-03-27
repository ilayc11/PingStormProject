#!/bin/bash

file="ResultsAnalysis.txt"

# Checking if the file  exists
if [ ! -f "$file" ]; then
    echo "❌ Error: $file not found!"
    exit 1
fi

# Extracting summary lines
slowest_line=$(grep "Slowest" $file)
fastest_line=$(grep "Fastest" $file)
overall_avg=$(grep "Overall avg latency" $file | awk '{print $NF}')

#Extract values
slowest_site=$(echo $slowest_line | awk '{print $2}')
slowest_val=$(echo $slowest_line | awk '{print $3}')
fastest_site=$(echo $fastest_line | awk '{print $2}')
fastest_val=$(echo $fastest_line | awk '{print $3}')

#Print report header
echo ""
echo "🌐 PINGSTORM REPORT"
echo "========================================"
echo "Average Latency: ${overall_avg} ms"
echo ""
echo "✅ Fastest: $fastest_site (${fastest_val} ms)"
echo "😢 Slowest: $slowest_site (${slowest_val} ms)"
echo ""
echo "Visual:"

#Extract and draw ranking list
ranking_start=$(grep -n "Ranking:" $file | cut -d: -f1)
ranking_end=$(grep -n "Overall avg latency" $file | cut -d: -f1)

ranking_lines=$(tail -n +"$((ranking_start + 1))" "$file" | head -n "$((ranking_end - ranking_start - 1))")

#Loop and draw bars
echo "$ranking_lines" | while read line; do
    site=$(echo $line | awk '{print $1}')
    latency=$(echo $line | awk '{print $2}')
    
    # Create bar: 1 block = 2 ms
    blocks=$((latency / 2))
    bar=$(printf '█%.0s' $(seq 1 $blocks))
    
    # Align output
    printf "%-13s | %-20s %s ms\n" "$site" "$bar" "$latency"
done

echo ""
