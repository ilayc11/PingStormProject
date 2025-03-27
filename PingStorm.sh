#!/bin/bash

# ======================================================
# TCP - TechCyberPoint | Bash Ping Checker Script
# File: PingStorm.sh
# Author: Yosi Leviev + Ofir Or
# Description: Perform ping tests on targets listed in TargetPing.txt
# Outputs: PingResults.txt (results), ping_log.txt (logs)
# ======================================================

TARGET_FILE="TargetPing.txt"
RESULT_FILE="PingResults.txt"
LOG_FILE="ping_log.txt"
SCRIPT_NAME="PingStorm.sh"

# ---------- Terminal Colors ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# ---------- Logging Function ----------
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
    "ERROR") echo -e "${RED}$log_line${NC}" ;;
    "SUCCESS") echo -e "${GREEN}$log_line${NC}" ;;
    "WARN") echo -e "${YELLOW}$log_line${NC}" ;;
    *) echo "$log_line" ;;
  esac
}

# ---------- Prepare Files ----------
touch "$RESULT_FILE" "$LOG_FILE"
log_msg "INFO" "init" "Script started"

if [ "$EUID" -ne 0 ]; then
  log_msg "INFO" "permission" "Running as regular user"
else
  log_msg "INFO" "permission" "Running as root user"
fi

if [ ! -f "$TARGET_FILE" ]; then
  log_msg "ERROR" "init" "Target file '$TARGET_FILE' not found"
  echo "File $TARGET_FILE is missing. Exiting."
  exit 1
fi

# ---------- Ping Function ----------
ping_target() {
  local domain=$1
  local ip_address=$(getent hosts "$domain" | awk '{ print $1 }')

  if [ -z "$ip_address" ]; then
    log_msg "ERROR" "ping_target" "DNS resolution failed for $domain"
    echo -e "$domain - - - DNS_Resolution_Failed -" >> "$RESULT_FILE"
    return
  fi

  log_msg "INFO" "ping_target" "Starting ping test for $domain ($ip_address)"

  local success=0
  local fail=0
  local total_time=0
  local count=0
  local times=()

  while read -r line; do
    if [[ $line == *"bytes from"* ]]; then
      time_val=$(echo "$line" | grep -o "time=[0-9.]* ms" | cut -d= -f2 | cut -d' ' -f1)
      times+=($time_val)
      total_time=$(echo "$total_time + $time_val" | bc)
      ((success++))
    elif [[ $line == *"Destination Host Unreachable"* || $line == *"Request timeout"* ]]; then
      times+=("-")
      ((fail++))
    fi
    ((count++))
  done < <(ping -c 5 "$domain")

  local avg_time
  if [ "$success" -gt 0 ]; then
    avg_time=$(echo "scale=2; $total_time / $success" | bc)
  else
    avg_time="N/A"
  fi

  echo -e "$domain ${times[@]} $avg_time" >> "$RESULT_FILE"
  log_msg "SUCCESS" "ping_target" "Completed ping for $domain | Success: $success, Fail: $fail, Avg: $avg_time ms"
}

# ---------- Loop Through Targets ----------
log_msg "INFO" "main" "Starting all ping tests"

while read -r domain; do
  [[ -z "$domain" ]] && continue
  ping_target "$domain"
done < "$TARGET_FILE"

log_msg "SUCCESS" "main" "All ping tests completed"
