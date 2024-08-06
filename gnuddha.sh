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

FLAG_F=false
FRAME_RATE=24

FRAME_UP=1
FRAME_INDEX=1
SLEEP_DUR=$(echo "scale=2; 1 / $FRAME_RATE" | bc)

OVER=false

CURRENT_TIME=$(date +%s)
LAST_TIME=$(date +%s)
# echo "DUR : ${SLEEP_DUR}"

# Function to handle window resize
handle_resize() {
    clear
}
trap handle_resize WINCH

# Cleanup function to run on script exit
cleanup() {
    SESSION_LENGTH=$(bc <<< "scale=2; ${TOTAL}/60")
    echo -en "\007"
}
trap cleanup EXIT

fetchQuote() {
    api_data=$(curl -s "https://buddha-api.com/api/random")
    BY_NAME=$(echo "$api_data" | jq -r '.byName')
    QUOTE=$(echo "$api_data" | jq -r '.text')
}

splitQuote() {
    words=($QUOTE)
    local max_length=24

    lines=()
    local result=""

    for word in ${words[@]}; do 
        length_test=$(( ${#result} + ${#word} + 1 ))  # +1 for space between words

        if (( length_test > max_length )); then 
            lines+=("$result")
            echo -e "\t\t${result}"
            result="$word"  # Start new line with the current word
        else 
            if [[ -n $result ]]; then
                result+=$' '$word  # Add space between words
            else
                result=$word
            fi
        fi 
    done

    if [[ -n $result ]]; then
        lines+=("$result")
        echo -e "\t\t${result}"
    fi
}

# Function to iterate and display content
iterate() {
    clear
    echo -e "\n\n"
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
    
    # calculate delta time
    CURRENT_TIME=$(date +%s)
    DELTA=$((CURRENT_TIME - LAST_TIME))
    LAST_TIME=$CURRENT_TIME

    TOTAL=$(echo "scale=2; $TOTAL + $DELTA" | bc)

    frame=$((FRAME_INDEX % 12))
    line_index=0

    local last_quote_line=444

    while read -r line; do
    if [[ "$OVER" == false ]]; then
        if ((line_index == 3)); then
            echo -e "$line\tTotal time: ${TOTAL} seconds"
        elif ((line_index == 5)); then
            echo -e "$line\t${lines[0]}"
            last_quote_line=5
        elif ((line_index == 6 && ${#lines[@]} >= 1)); then
            echo -e "$line\t${lines[1]}"
            last_quote_line=6
        elif ((line_index == 7 && ${#lines[@]} >= 2)); then
            echo -e "$line\t${lines[2]}"
            last_quote_line=7
        elif ((line_index == 8 && ${#lines[@]} >= 3)); then
            echo -e "$line\t${lines[3]}"
            last_quote_line=8
        elif ((line_index == 9 && ${#lines[@]} >= 4)); then
            echo -e "$line\t${lines[4]}"
            last_quote_line=9
        elif ((line_index == 10 && ${#lines[@]} >= 5)); then
            echo -e "$line\t${lines[5]}"
            last_quote_line=10
        elif ((line_index == 11 && ${#lines[@]} >= 6)); then
            echo -e "$line\t${lines[6]}"
            last_quote_line=11
        elif ((line_index == last_quote_line + 1)); then 
            echo -e "$line\t${BY_NAME}"
        else
            echo -e "$line"
        fi
        ((line_index++))
    else 
        if ((line_index == 6)); then
            echo -e "$line\tSee you next time."
        elif ((line_index == 7)); then 
            echo -e "$line\tDon't work too hard!"
        else 
            echo -e "$line"
        fi
        ((line_index++))
    fi
done < "b_frames/${frame}.txt"


    echo -e "\n"
    sleep "$SLEEP_DUR"
    if [[ "$OVER" == false ]]; then
        clear
    fi
}

# Usage function to display script usage
usage() {
    echo "Usage: $0 [-t time_in_minutes] [-v]"
    exit 1
}

# Parsing command-line options
while getopts ":t:f:" opt; do
    case ${opt} in
        t )
            FLAG_T=true
            SESSION_TIME=$OPTARG
            echo "Option -t set with value: $SESSION_TIME"
            ;;
        f )
            FLAG_F=true
            FRAME_RATE=$OPTARG
            echo "Option -f set with value: $FRAME_RATE"
            ;;
        \? )
            echo "Invalid option: -$OPTARG"
            usage
            ;;
        : )
            echo "Option -$OPTARG requires an argument."
            usage
            ;;
    esac
done
shift $((OPTIND -1))

SLEEP_DUR=$(echo "scale=2; 1 / $FRAME_RATE" | bc)

# Fetch the initial quote and format
fetchQuote
splitQuote


if [ "$FLAG_F" = true ]; then 
    echo FLAGFFRUE
    echo "$FRAME_RATE"
fi

# Main logic
if [ "$FLAG_T" = true ]; then
    
    if (( "$TOTAL < $((SESSION_TIME * 60))" | bc -l )); then echo "passed" 
    fi

    echo $OVER
    while ((OVER == false));
    do
        comparison_value=$(echo "$SESSION_TIME * 60" | bc -l)
        if [ "$(echo "$TOTAL < $comparison_value" | bc -l)" -eq 1 ]; then
            iterate
        else
            OVER=true
            iterate
            break
        fi
    done

else
    echo 'done'
fi
