#!/bin/bash

# Interactive control script for PingStorm

PINGSTORM_SCRIPT="./PingStorm.sh"
LOGFILE="pingstorm.log"
PIDFILE="pingstorm.pid"
TARGET_FILE="TargetPing.txt"

# Show the menu
echo "PingStorm Control Menu"
echo "Choose an option:"
echo "  1 - Start PingStorm"
echo "  2 - Stop PingStorm"
echo "  3 - Check if it's running"
echo "  4 - Show last 10 log lines"
read -p "Enter your choice (1-4): " CHOICE

if [ "$CHOICE" == "1" ]; then
    if [ ! -f "$TARGET_FILE" ]; then
        echo "'$TARGET_FILE' not found. Creating it with example websites..."
        cat > "$TARGET_FILE" <<EOF
google.com
facebook.com
tiktok.com
youtube.com
netflix.com
EOF
        echo "Created '$TARGET_FILE'. You can edit it if needed."
    fi

    if [ -f "$PIDFILE" ]; then
        echo "PingStorm is already running."
    else
        echo "Starting PingStorm..."
        bash $PINGSTORM_SCRIPT &
        echo $! > $PIDFILE
        echo "PingStorm started."
    fi

elif [ "$CHOICE" == "2" ]; then
    if [ -f "$PIDFILE" ]; then
        PID=$(cat $PIDFILE)
        echo "Stopping PingStorm (PID $PID)..."
        kill $PID
        rm $PIDFILE
        echo "PingStorm stopped."
    else
        echo "PingStorm is not running."
    fi

elif [ "$CHOICE" == "3" ]; then
    if [ -f "$PIDFILE" ]; then
        PID=$(cat $PIDFILE)
        if ps -p $PID > /dev/null; then
            echo "PingStorm is running (PID $PID)."
        else
            echo "PingStorm was running but stopped. Cleaning up..."
            rm $PIDFILE
        fi
    else
        echo "PingStorm is not running."
    fi

elif [ "$CHOICE" == "4" ]; then
    if [ -f "$LOGFILE" ]; then
        echo "Last 10 lines from the log:"
        tail -n 10 $LOGFILE
    else
        echo "No log file found yet."
    fi

else
    echo "Invalid option. Please run the script again and choose 1–4."
fi
