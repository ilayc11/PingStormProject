#!/bin/bash

# =========================================================
# Control.sh - PingStorm Control Panel
# Author: TechCyberPoint Team
# Description: Menu to start, stop, check or tail PingStorm
# =========================================================

PINGSTORM_SCRIPT="./PingStorm.sh"
LOG_FILE="ping_log.txt"
PID_FILE="pingstorm.pid"
TARGET_FILE="TargetPing.txt"
SCRIPT_NAME=$(basename "$0")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function (same format as other scripts)
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

# Display menu
echo -e "${YELLOW}"
echo "=========== PingStorm Control Menu ==========="
echo "Choose an option:"
echo "  1 - Start PingStorm"
echo "  2 - Stop PingStorm"
echo "  3 - Check if it's running"
echo "  4 - Show last 10 log lines"
echo -e "==============================================${NC}"
read -p "Enter your choice (1-4): " CHOICE

# Option 1 – Start
if [ "$CHOICE" == "1" ]; then
  if [ ! -f "$TARGET_FILE" ]; then
    log_msg "WARN" "start" "'$TARGET_FILE' not found. Creating default..."
    cat > "$TARGET_FILE" <<EOF
google.com
facebook.com
tiktok.com
youtube.com
netflix.com
EOF
    log_msg "INFO" "start" "Created '$TARGET_FILE'."
    echo "You can edit it manually before next run."
  fi

  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null; then
      log_msg "WARN" "start" "PingStorm is already running (PID $PID)"
      exit 0
    else
      rm "$PID_FILE"
    fi
  fi

  log_msg "INFO" "start" "Launching PingStorm..."
  bash "$PINGSTORM_SCRIPT" &
  echo $! > "$PID_FILE"
  sleep 1
  if ps -p $(cat "$PID_FILE") > /dev/null; then
    log_msg "SUCCESS" "start" "PingStorm started (PID $(cat $PID_FILE))"
  else
    log_msg "ERROR" "start" "PingStorm failed to start"
    rm "$PID_FILE"
  fi

# Option 2 – Stop
elif [ "$CHOICE" == "2" ]; then
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    log_msg "INFO" "stop" "Stopping PingStorm (PID $PID)..."
    kill "$PID" && rm "$PID_FILE"
    log_msg "SUCCESS" "stop" "PingStorm stopped"
  else
    log_msg "WARN" "stop" "PingStorm is not running"
  fi

# Option 3 – Check status
elif [ "$CHOICE" == "3" ]; then
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null; then
      log_msg "INFO" "check" "PingStorm is running (PID $PID)"
    else
      log_msg "WARN" "check" "PID file exists but process not running. Cleaning up."
      rm "$PID_FILE"
    fi
  else
    log_msg "INFO" "check" "PingStorm is not running"
  fi

# Option 4 – Tail log
elif [ "$CHOICE" == "4" ]; then
  if [ -f "$LOG_FILE" ]; then
    echo -e "\n🔍 Last 10 lines from $LOG_FILE:\n"
    tail -n 10 "$LOG_FILE"
    echo ""
  else
    log_msg "ERROR" "log" "Log file not found"
  fi

# Invalid input
else
  log_msg "ERROR" "menu" "Invalid option. Please choose between 1–4."
fi
