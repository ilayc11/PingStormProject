#!/bin/bash

# ==========================================================
# visualization.sh – Report & Graphical Output for PingStorm
# Author: TechCyberPoint Team
# ==========================================================

FILE="ResultsAnalysis.txt"
LOG_FILE="pingstorm.log"
SCRIPT_NAME=$(basename "$0")

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function (standardized)
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

# ========== Script starts here ==========

log_msg "INFO" "init" "Starting visualization script"

if [ ! -f "$FILE" ]; then
  log_msg "ERROR" "init" "'$FILE' not found"
  echo "❌ Error: $FILE not found!"
  exit 1
fi

# Extract summary lines
slowest_line=$(grep "Slowest" "$FILE")
fastest_line=$(grep "Fastest" "$FILE")
overall_avg=$(grep "Overall avg latency" "$FILE" | awk '{print $NF}')

slowest_site=$(echo "$slowest_line" | awk '{print $2}')
slowest_val=$(echo "$slowest_line" | awk '{print $3}')
fastest_site=$(echo "$fastest_line" | awk '{print $2}')
fastest_val=$(echo "$fastest_line" | awk '{print $3}')

# Print report header
echo -e "\n${YELLOW}🌐 PINGSTORM REPORT${NC}"
echo    "========================================"
echo -e "📊 Average Latency: ${BLUE}${overall_avg} ms${NC}\n"
echo -e "✅ Fastest: ${GREEN}${fastest_site} (${fastest_val} ms)${NC}"
echo -e "🐢 Slowest: ${RED}${slowest_site} (${slowest_val} ms)${NC}"
echo    "========================================"
echo -e "${BLUE}Latency Ranking Visual:${NC}"

echo ""

ranking_start=$(grep -n "Ranking:" "$FILE" | cut -d: -f1)
ranking_end=$(grep -n "Overall avg latency" "$FILE" | cut -d: -f1)

if [[ -z "$ranking_start" || -z "$ranking_end" ]]; then
  log_msg "ERROR" "visual" "Ranking section not found in file"
  echo -e "${RED}Ranking data not found in $FILE${NC}"
  exit 1
fi

ranking_lines=$(tail -n +$((ranking_start + 1)) "$FILE" | head -n $((ranking_end - ranking_start - 1)))

valid_rows=0
while read -r line; do
  [[ -z "$line" ]] && continue
  site=$(echo "$line" | awk '{print $1}')
  latency=$(echo "$line" | awk '{print $2}')

  if [[ "$latency" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    blocks=$(echo "$latency / 2" | bc)
    bar=$(printf '█%.0s' $(seq 1 $blocks))
    printf "%-15s | %-30s %s ms\n" "$site" "$bar" "$latency"
    ((valid_rows++))
  fi

done <<< "$ranking_lines"

if [[ $valid_rows -eq 0 ]]; then
  echo -e "${RED}⚠ No valid latency data found for visualization.${NC}"
  log_msg "WARN" "visual" "No valid rows were drawn in chart"
fi

log_msg "SUCCESS" "main" "Visualization report completed"
echo ""
