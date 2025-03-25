#!/bin/bash
SlowestAndFastest() {
	fastestTime=9999999
	fastestSite=""
	slowestTime=0
	slowestSite=""
	while read -r site t1 t2 t3 t4 t5 avgT; do 
	if [[ -z "$site" ]]; then
		continue
	fi
		for time in $t1 $t2 $t3 $t4 $t5; do
			#fastest
			if (( $(echo "$time < $fastestTime" | bc -l) )); then
				fastestTime=$time
				fastestSite=$site
			fi
			#slowest
			if (( $(echo "$time > $slowestTime" | bc -l) )); then
				slowestTime=$time
				slowestSite=$site
			fi
		done
	done < "$input_file"
	echo "Slowest: $slowestSite $slowestTime" >> ResultsAnalysis.txt
	echo "Fastest: $fastestSite $fastestTime" >> ResultsAnalysis.txt
}

RankByAvg(){
	echo "Ranking:" >> ResultsAnalysis.txt
	sort -k7 -n "$input_file" | awk '{print $1}' >> ResultsAnalysis.txt
}


calculateAvgOfAvg(){
	avgSum=0
	numberOfSites=0
	while read -r site t1 t2 t3 t4 t5 avgT; do 
		if [[ -z "$site" ]]; then
			continue
		fi
		(( avgSum = avgSum + avgT ))
		(( numberOfSites = numberOfSites + 1 ))
	done < "$input_file"
	echo "Overall avg latency: $(echo "scale=3; $avgSum / $numberOfSites" | bc -l)" >> ResultsAnalysis.txt
}

input_file="PingResults.txt"
SlowestAndFastest
RankByAvg
calculateAvgOfAvg



