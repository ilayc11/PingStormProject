#!/bin/bash

# ======================================================
# TCP - TechCyberPoint | Bash Ping Checker Script
# File: PingStorm.sh
# Author: Yosi Leviev + Ofir Or + 
# Description: Perform ping tests on targets listed in TargetPing.txt
# Outputs: PingResults.txt (results), ping_log.txt (logs)
# ======================================================

# ---------- קבצים ----------
TARGET_FILE="TargetPing.txt"
RESULT_FILE="PingResults.txt"
LOG_FILE="ping_log.txt"
SCRIPT_NAME="PingStorm.sh"

# ---------- צבעים ללוגים במסך ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# ---------- פונקציית לוגים משופרת ----------
log_msg() {
  local type=$1
  local source=$2
  local message=$3
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  local log_line="[${timestamp}] | ${type} | ${SCRIPT_NAME}/${source} | ${message}"
  echo "$log_line" >> "$LOG_FILE"

  # צבעים למסך
  case "$type" in
    "INFO") echo -e "${BLUE}$log_line${NC}" ;;
    "ERROR") echo -e "${RED}$log_line${NC}" ;;
    "SUCCESS") echo -e "${GREEN}$log_line${NC}" ;;
    "WARN") echo -e "${YELLOW}$log_line${NC}" ;;
    *) echo "$log_line" ;;
  esac
}

# ---------- הכנת קבצים ----------
touch "$RESULT_FILE" "$LOG_FILE"
log_msg "INFO" "init" "Script started"

# ---------- בדיקת הרשאות ----------
if [ "$EUID" -ne 0 ]; then
  log_msg "INFO" "permission" "Running as regular user"
else
  log_msg "INFO" "permission" "Running as root user"
fi

# ---------- בדיקת קובץ יעדים ----------
if [ ! -f "$TARGET_FILE" ]; then
  log_msg "ERROR" "init" "Target file '$TARGET_FILE' not found"
  echo "File $TARGET_FILE is missing. Exiting."
  exit 1
fi

# ---------- פונקציית בדיקת פינג ----------
ping_target() {
  local domain=$1
  local ip_address
  ip_address=$(getent hosts "$domain" | awk '{ print $1 }')

  if [ -z "$ip_address" ]; then
    log_msg "ERROR" "ping_target" "DNS resolution failed for $domain"
    echo "===== PING RESULTS FOR: $domain =====" >> "$RESULT_FILE"
    echo "1. Domain/IP - DNS = $domain / Resolution Failed" >> "$RESULT_FILE"
    echo "2. icmp_seq = -" >> "$RESULT_FILE"
    echo "3. time = -" >> "$RESULT_FILE"
    echo "4. Error Code = DNS Resolution Failed" >> "$RESULT_FILE"
    echo "5. Result = Failed" >> "$RESULT_FILE"
    echo "----------------------------------------" >> "$RESULT_FILE"
    return
  fi

  log_msg "INFO" "ping_target" "Starting ping test for $domain ($ip_address)"
  echo "===== PING RESULTS FOR: $domain =====" >> "$RESULT_FILE"

  # משתנים לסיכום
  local success=0
  local fail=0
  local total_time=0
  local count=0

  # הרצת פינג
  while read -r line; do
    if [[ $line == *"bytes from"* ]]; then
      seq=$(echo "$line" | grep -o "icmp_seq=[0-9]*" | cut -d= -f2)
      time_val=$(echo "$line" | grep -o "time=[0-9.]* ms" | cut -d= -f2)
      time_num=$(echo "$time_val" | cut -d' ' -f1)

      echo "1. Domain/IP - DNS = $domain / $ip_address" >> "$RESULT_FILE"
      echo "2. icmp_seq = $seq" >> "$RESULT_FILE"
      echo "3. time = $time_val" >> "$RESULT_FILE"
      echo "4. Error Code = " >> "$RESULT_FILE"
      echo "5. Result = Success" >> "$RESULT_FILE"
      echo "----------------------------------------" >> "$RESULT_FILE"

      ((success++))
      total_time=$(echo "$total_time + $time_num" | bc)
    elif [[ $line == *"Destination Host Unreachable"* || $line == *"Request timeout"* ]]; then
      seq=$(echo "$line" | grep -o "icmp_seq=[0-9]*" | cut -d= -f2)
      echo "1. Domain/IP - DNS = $domain / $ip_address" >> "$RESULT_FILE"
      echo "2. icmp_seq = ${seq:-N/A}" >> "$RESULT_FILE"
      echo "3. time = -" >> "$RESULT_FILE"
      echo "4. Error Code = No Response" >> "$RESULT_FILE"
      echo "5. Result = Failed" >> "$RESULT_FILE"
      echo "----------------------------------------" >> "$RESULT_FILE"
      ((fail++))
    fi
    ((count++))
  done < <(ping -c 5 "$domain")

  # ממוצע זמן
  local avg_time
  if [ "$success" -gt 0 ]; then
    avg_time=$(echo "scale=2; $total_time / $success" | bc)
  else
    avg_time="N/A"
  fi

  # סיכום
  echo "=================" >> "$RESULT_FILE"
  echo "Results for $domain:" >> "$RESULT_FILE"
  echo "Action: Ping Test Completed" >> "$RESULT_FILE"
  echo "Count: Success=$success | Failed=$fail | Total=$count" >> "$RESULT_FILE"
  echo "AVARAGE MS: $avg_time" >> "$RESULT_FILE"
  echo "=================" >> "$RESULT_FILE"

  log_msg "SUCCESS" "ping_target" "Completed ping for $domain | Success: $success, Fail: $fail, Avg: $avg_time ms"
}

# ---------- לולאה על כל הדומיינים ----------
log_msg "INFO" "main" "Starting all ping tests"

while read -r domain; do
  [[ -z "$domain" ]] && continue
  ping_target "$domain"
done < "$TARGET_FILE"

<<<<<<< HEAD
log_msg "SUCCESS" "main" "All ping tests completed"
=======
log_msg "SUCCESS" "main" "All ping tests completed"
>>>>>>> Target-Service-List-and-Ping-Execution
