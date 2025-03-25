#!/bin/bash
input_file="PingResults.txt"
log_file="pingstorm.log"



logToLog(){
	timestamp=$(date +"%d/%m/%Y %H:%M:%S")
	echo "$timestamp [$1] $2 $3" >> "$log_file"
}

SlowestAndFastest() {
	logToLog "INFO" "ResultsAnalysis.sh" "starting_search_Slowest_And_Fastest"
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
	logToLog "INFO" "ResultsAnalysis.sh" "found_Slowest_And_Fastest"
	echo "Slowest: $slowestSite $slowestTime" >> ResultsAnalysis.txt
	echo "Fastest: $fastestSite $fastestTime" >> ResultsAnalysis.txt
	logToLog "INFO" "ResultsAnalysis.sh" "wrote_slowest_and_fastest_to_$input_file"
}

RankByAvg(){
	logToLog "INFO" "ResultsAnalysis.sh" "starting_Rank_By_Avg"
	echo "Ranking:" >> ResultsAnalysis.txt
	sort -k7 -n "$input_file" | awk '{print $1}' >> ResultsAnalysis.txt
	logToLog "INFO" "ResultsAnalysis.sh" "wrote_ranking_to_$input_file"
}


calculateAvgOfAvg(){
	logToLog "INFO" "ResultsAnalysis.sh" "starting_avg_of_avg_calculation"
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
	logToLog "INFO" "ResultsAnalysis.sh" "wrote_avg_of_avg_to_$input_file"
}


logToLog "INFO" "ResultsAnalysis.sh" "started_script"

if [[ ! -e "$input_file" ]]; then
	echo "input file doesnt exist!"
	logToLog "ERROR" "ResultsAnalysis.sh" "input_file_doesnt_exist"
	exit
elif [[ -z "$input_file" ]]; then
	echo "input file doesnt include sites!"
	logToLog "ERROR" "ResultsAnalysis.sh" "input_file_is_empty"
	exit
fi

SlowestAndFastest
RankByAvg
calculateAvgOfAvg

logToLog "INFO" "ResultsAnalysis.sh" "finished_script"



