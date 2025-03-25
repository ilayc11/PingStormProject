#!/bin/bash

input_file="PingResults.txt"
output_file="ResultsAnalysis.txt"
log_file="pingstorm.log"
script_name=$(basename "$0")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

logToLog() {
	local type=$1
	local source=$2
	local message=$3
	local timestamp
	timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	local log_line="[${timestamp}] | ${type} | ${script_name}/${source} | ${message}"
	echo "$log_line" >> "$log_file"
	
	case "$type" in
		"INFO") echo -e "${BLUE}$log_line${NC}" ;;
		"ERROR") echo -e "${RED}$log_line${NC}" ;;
		"SUCCESS") echo -e "${GREEN}$log_line${NC}" ;;
		"WARN") echo -e "${YELLOW}$log_line${NC}" ;;
		*) echo "$log_line" ;;
	esac
}

SlowestAndFastest() {
	logToLog "INFO" "SlowestAndFastest" "Starting search for Slowest and Fastest"

	local fastestTime=9999999
	local fastestSite=""
	local slowestTime=0
	local slowestSite=""

	while read -r site t1 t2 t3 t4 t5 avgT; do
		[[ -z "$site" || -z "$avgT" || ! "$avgT" =~ ^[0-9]+(\.[0-9]+)?$ ]] && continue
		
		# Fastest
		if (( $(echo "$avgT < $fastestTime" | bc -l) )); then
			fastestTime=$avgT
			fastestSite=$site
		fi

		# Slowest
		if (( $(echo "$avgT > $slowestTime" | bc -l) )); then
			slowestTime=$avgT
			slowestSite=$site
		fi
	done < "$input_file"
	logToLog "INFO" "SlowestAndFastest" "Found slowest and fastest sites"

	if [[ -n "$slowestSite" && -n "$fastestSite" ]]; then
		echo "Slowest: $slowestSite $slowestTime" >> "$output_file"
		echo "Fastest: $fastestSite $fastestTime" >> "$output_file"
		logToLog "INFO" "SlowestAndFastest" "wrote to output file"

	else
		logToLog "ERROR" "SlowestAndFastest" "Failed to determine slowest and fastest"
	fi
}

RankByAvg() {
	logToLog "INFO" "RankByAvg" "Starting ranking by average"

	echo "Ranking:" >> "$output_file"
	if sort -k7 -n "$input_file" | awk '{print $1, $7}' >> "$output_file"; then
		logToLog "INFO" "RankByAvg" "Wrote ranking to $output_file"
	else
		logToLog "ERROR" "RankByAvg" "Failed to rank sites"
	fi
}

calculateAvgOfAvg() {
	logToLog "INFO" "calculateAvgOfAvg" "Starting avg-of-avg calculation"

	local avgSum=0
	local numberOfSites=0

	while read -r site t1 t2 t3 t4 t5 avgT; do
		[[ -z "$site" || -z "$avgT" ]] && continue
		
		avgSum=$(echo "$avgSum + $avgT" | bc -l)
		(( numberOfSites++ ))
	done < "$input_file"

	if (( numberOfSites > 0 )); then
		echo "Overall avg latency: $(echo "scale=3; $avgSum / $numberOfSites" | bc -l)" >> "$output_file"
		logToLog "INFO" "calculateAvgOfAvg" "Calculated avg-of-avg successfully"
	else
		logToLog "ERROR" "calculateAvgOfAvg" "No valid data to calculate avg-of-avg"
	fi
}

# Script execution starts here
logToLog "INFO" "init" "Script started"

# Validate input file
if [[ ! -f "$input_file" ]]; then
	echo "Error: Input file does not exist!"
	logToLog "ERROR" "init" "Input file does not exist"
	exit 1
fi

if [[ ! -s "$input_file" ]]; then
	echo "Error: Input file is empty!"
	logToLog "ERROR" "init" "Input file is empty"
	exit 1
fi

# Clear output file at the start to avoid appending to old results
> "$output_file"
logToLog "INFO" "init" "input file exist and valid"

logToLog "INFO" "main" "starting main analysis"


SlowestAndFastest
RankByAvg
calculateAvgOfAvg

logToLog "SUCCESS" "main" "Finished script successfully"
