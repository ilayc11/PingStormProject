#!/bin/bash

# =====================================================
# ResultsAnalysis.sh – Analyzer for PingStorm Results
# Author: TechCyberPoint Team
# Description: Analyzes PingResults.txt for insights
# =====================================================

INPUT_FILE="PingResults.txt"
OUTPUT_FILE="ResultsAnalysis.txt"
LOG_FILE="pingstorm.log"
SCRIPT_NAME=$(basename "$0")

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function (standardized across project)
log_msg() {
	local type=$1
	local source=$2
	local message=$3
	local timestamp
	timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	local log_line="[${timestamp}] | ${type} | ${SCRIPT_NAME}/${source} | ${message}"
	echo "$log_line" >> "$LOG_FILE"

	case "$type" in
		"INFO") echo -e "${BLUE}$log_line${NC}" ;;
		"SUCCESS") echo -e "${GREEN}$log_line${NC}" ;;
		"ERROR") echo -e "${RED}$log_line${NC}" ;;
		"WARN") echo -e "${YELLOW}$log_line${NC}" ;;
		*) echo "$log_line" ;;
	esac
}

# -----------------------------------------------------
# Function: Identify the slowest and fastest domain
# -----------------------------------------------------
find_slowest_and_fastest() {
	log_msg "INFO" "find_slowest_and_fastest" "Analyzing slowest and fastest domains..."

	local fastest_time=9999999
	local fastest_site=""
	local slowest_time=0
	local slowest_site=""

	while read -r site t1 t2 t3 t4 t5 avg; do
		[[ -z "$site" || -z "$avg" || ! "$avg" =~ ^[0-9]+(\.[0-9]+)?$ ]] && continue

		if (( $(echo "$avg < $fastest_time" | bc -l) )); then
			fastest_time=$avg
			fastest_site=$site
		fi
		if (( $(echo "$avg > $slowest_time" | bc -l) )); then
			slowest_time=$avg
			slowest_site=$site
		fi
	done < "$INPUT_FILE"

	if [[ -n "$fastest_site" && -n "$slowest_site" ]]; then
		echo "Slowest: $slowest_site $slowest_time" >> "$OUTPUT_FILE"
		echo "Fastest: $fastest_site $fastest_time" >> "$OUTPUT_FILE"
		log_msg "SUCCESS" "find_slowest_and_fastest" "Summary written to output file"
	else
		log_msg "ERROR" "find_slowest_and_fastest" "Could not determine slowest/fastest"
	fi
}

# -----------------------------------------------------
# Function: Rank domains by average latency
# -----------------------------------------------------
rank_by_avg_latency() {
	log_msg "INFO" "rank_by_avg_latency" "Sorting domains by average latency..."

	echo "Ranking:" >> "$OUTPUT_FILE"
	if sort -k7 -n "$INPUT_FILE" | awk '{print $1, $7}' >> "$OUTPUT_FILE"; then
		log_msg "SUCCESS" "rank_by_avg_latency" "Ranking written to output file"
	else
		log_msg "ERROR" "rank_by_avg_latency" "Failed to write ranking"
	fi
}

# -----------------------------------------------------
# Function: Calculate overall average of all avg latencies
# -----------------------------------------------------
calculate_avg_of_avg() {
	log_msg "INFO" "calculate_avg_of_avg" "Calculating global average..."

	local total=0
	local count=0

	while read -r site t1 t2 t3 t4 t5 avg; do
		[[ -z "$site" || -z "$avg" || ! "$avg" =~ ^[0-9]+(\.[0-9]+)?$ ]] && continue
		total=$(echo "$total + $avg" | bc -l)
		((count++))
	done < "$INPUT_FILE"

	if (( count > 0 )); then
		local result=$(echo "scale=3; $total / $count" | bc -l)
		echo "Overall avg latency: $result" >> "$OUTPUT_FILE"
		log_msg "SUCCESS" "calculate_avg_of_avg" "Global avg: $result"
	else
		log_msg "ERROR" "calculate_avg_of_avg" "No data for avg-of-avg"
	fi
}

# -----------------------------------------------------
# Execution starts here
# -----------------------------------------------------

log_msg "INFO" "init" "Analysis script started."

# Validate input file
if [[ ! -f "$INPUT_FILE" ]]; then
	log_msg "ERROR" "init" "Input file '$INPUT_FILE' does not exist"
	exit 1
fi

if [[ ! -s "$INPUT_FILE" ]]; then
	log_msg "ERROR" "init" "Input file '$INPUT_FILE' is empty"
	exit 1
fi

# Clear previous output
> "$OUTPUT_FILE"
log_msg "INFO" "init" "Input file is valid. Output file cleared."

# Run analysis
find_slowest_and_fastest
rank_by_avg_latency
calculate_avg_of_avg

log_msg "SUCCESS" "main" "Analysis completed successfully."
