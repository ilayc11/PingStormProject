#!/bin/bash

# ======================================================
# TCP - TechCyberPoint | Bash Ping Checker Script
# Author: Yosi (and team)
# Description: Perform ping tests on targets listed in TargetPing.txt
# Outputs: PingResults.txt (results), ping_log.txt (logs)
# ======================================================

# ---------- הגדרות קבצים ----------
TARGET_FILE="TargetPing.txt"
RESULT_FILE="PingResults.txt"
LOG_FILE="ping_log.txt"

# ---------- הכנת קבצים ----------
# נוודא שהקבצים קיימים או ניצור אותם
touch "$RESULT_FILE"
touch "$LOG_FILE"

# ---------- בדיקת הרשאות משתמש ----------
if [ "$EUID" -ne 0 ]; then
  echo "[INFO] $(date) - Running as regular user" >> "$LOG_FILE"
else
  echo "[INFO] $(date) - Running as root user" >> "$LOG_FILE"
fi

# ---------- בדיקת קיום קובץ יעדים ----------
if [ ! -f "$TARGET_FILE" ]; then
  echo "[ERROR] $(date) - Target file '$TARGET_FILE' not found!" >> "$LOG_FILE"
  echo "Target file '$TARGET_FILE' is missing. Exiting."
  exit 1
fi

# ---------- פונקציית ביצוע פינג ----------
ping_target() {
  local domain=$1
  local ip_address
  ip_address=$(getent hosts "$domain" | awk '{ print $1 }')

  if [ -z "$ip_address" ]; then
    echo "[ERROR] $(date) - Failed to resolve $domain" >> "$LOG_FILE"
    echo "===== PING RESULTS FOR: $domain =====" >> "$RESULT_FILE"
    echo "1. Domain/IP - DNS = $domain / Resolution Failed" >> "$RESULT_FILE"
    echo "2. icmp_seq = -" >> "$RESULT_FILE"
    echo "3. time = -" >> "$RESULT_FILE"
    echo "4. Error Code = DNS Resolution Failed" >> "$RESULT_FILE"
    echo "5. Result = Failed" >> "$RESULT_FILE"
    echo "----------------------------------------" >> "$RESULT_FILE"
    return
  fi

  echo "[INFO] $(date) - Starting ping test for $domain ($ip_address)" >> "$LOG_FILE"
  echo "===== PING RESULTS FOR: $domain =====" >> "$RESULT_FILE"

  # הרצת 5 ניסיונות פינג
  ping -c 5 "$domain" | while read -r line; do
    # רק שורות עם פינג מוצלח
    if [[ $line == *"bytes from"* ]]; then
      seq=$(echo "$line" | grep -o "icmp_seq=[0-9]*" | cut -d= -f2)
      time_val=$(echo "$line" | grep -o "time=[0-9.]* ms" | cut -d= -f2)
      echo "1. Domain/IP - DNS = $domain / $ip_address" >> "$RESULT_FILE"
      echo "2. icmp_seq = $seq" >> "$RESULT_FILE"
      echo "3. time = $time_val" >> "$RESULT_FILE"
      echo "4. Error Code = " >> "$RESULT_FILE"
      echo "5. Result = Success" >> "$RESULT_FILE"
      echo "----------------------------------------" >> "$RESULT_FILE"
    elif [[ $line == *"Destination Host Unreachable"* || $line == *"Request timeout"* ]]; then
      seq=$(echo "$line" | grep -o "icmp_seq=[0-9]*" | cut -d= -f2)
      echo "1. Domain/IP - DNS = $domain / $ip_address" >> "$RESULT_FILE"
      echo "2. icmp_seq = ${seq:-N/A}" >> "$RESULT_FILE"
      echo "3. time = -" >> "$RESULT_FILE"
      echo "4. Error Code = No Response" >> "$RESULT_FILE"
      echo "5. Result = Failed" >> "$RESULT_FILE"
      echo "----------------------------------------" >> "$RESULT_FILE"
    fi
  done

  echo "[INFO] $(date) - Completed ping test for $domain" >> "$LOG_FILE"
}

# ---------- התחלת בדיקות ----------
echo "[INFO] $(date) - Starting all ping tests..." >> "$LOG_FILE"

while read -r domain; do
  # מדלגים על שורות ריקות
  [[ -z "$domain" ]] && continue
  ping_target "$domain"
done < "$TARGET_FILE"

echo "[INFO] $(date) - All ping tests completed." >> "$LOG_FILE"
