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

FRAME_RATE=24
FRAME_UP=1
FRAME_INDEX=1
SLEEP_DUR=$(echo "scale=2; 1 / $FRAME_RATE" | bc)
# echo "DUR : ${SLEEP_DUR}"



# Function to handle window resize
handle_resize() {
    clear
}
trap handle_resize WINCH

# Cleanup function to run on script exit
cleanup() {
    clear
    cat b_frames/0.txt
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
    if (( FRAME_INDEX == 11 )); then
        FRAME_UP=0
    fi

    if (( FRAME_INDEX == 0 )); then
        FRAME_UP=1
    fi

    if (( FRAME_UP == 1 )); then
        FRAME_INDEX=$((FRAME_INDEX+1))
    else 
        FRAME_INDEX=$((FRAME_INDEX-1))
    fi
    
    frame=$((FRAME_INDEX % 12))
    cat "b_frames/${frame}.txt"
    echo -e "\n${QUOTE}" | fold -w 32 -s
    echo -e "\t- ${BY_NAME}"
    TOTAL=$(echo "scale=2; $TOTAL + $SLEEP_DUR" | bc)
    echo -e "\n\nTotal time: ${TOTAL} seconds" 
    sleep "$SLEEP_DUR"
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

# Fetch the initial quote
fetchQuote

# Main logic
if [ "$FLAG_T" = true ]; then
    echo "t: $TOTAL"
    echo "st: $SESSION_TIME"

    echo HERE
    
    if (( "$TOTAL < $((SESSION_TIME * 60))" | bc -l )); then echo "passed" 
    fi

    

    while :
    do
        comparison_value=$(echo "$SESSION_TIME * 60" | bc -l)
        if [ "$(echo "$TOTAL < $comparison_value" | bc -l)" -eq 1 ]; then
            iterate
        else
            echo "TOTAL ($TOTAL) is not less than SESSION_TIME ($SESSION_TIME) * 60"
        fi
    done
else
    echo 'done'
fi
