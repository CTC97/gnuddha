#!/bin/bash

# Color codes
RED='\033[31m'
CYAN='\033[0;36m'
NC='\033[0m'
TOTAL=0

# Flags and variables
FLAG_T=false
SESSION_TIME=0

BY_NAME=""
QUOTE=""

# Function to handle window resize
handle_resize() {
    clear
}
trap handle_resize WINCH

# Cleanup function to run on script exit
cleanup() {
    clear
    cat buddha.txt
    SESSION_LENGTH=$(bc <<< "scale=2; ${TOTAL}/60")
    echo -en "\007"
    echo -e "\n\nSee you next time! Don't work too hard." | fold -w 32 -s
}
trap cleanup EXIT

# Function to fetch a random quote
fetchQuote() {
    api_data=$(curl -s "https://buddha-api.com/api/random")
    BY_NAME=$(echo "$api_data" | jq -r '.byName')
    QUOTE=$(echo "$api_data" | jq -r '.text')
}

# Function to iterate and display content
iterate() {
    clear
    cat buddha.txt
    echo -e "\n${QUOTE}" | fold -w 32 -s
    echo -e "\t- ${BY_NAME}"
    TOTAL=$((TOTAL + 1))
    echo -e "\n\nTotal time: ${TOTAL} seconds" 
    sleep 1
    clear
}

# Usage function to display script usage
usage() {
    echo "Usage: $0 [-t time_in_minutes] [-v]"
    exit 1
}

# Parsing command-line options
while getopts ":t:v" opt; do
    case ${opt} in
        t )
            FLAG_T=true
            SESSION_TIME=$OPTARG
            echo "Option -t set with value: $SESSION_TIME"
            ;;
        \? )
            echo "Invalid option: -$OPTARG"
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Debug output to check value_t
echo "Debug: flag_t=$flag_t, value_t=$value_t"

# Fetch the initial quote
fetchQuote

# Main logic
if [ "$FLAG_T" = true ]; then
    while [ "$TOTAL" -lt $((SESSION_TIME * 60)) ]; do
        iterate
    done
else
    echo 'done'
fi
