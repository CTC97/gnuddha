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

FLAG_C=false
COLOR="\033[0m"
RESET_COLOR="\033[0m"

FRAME_UP=1
FRAME_INDEX=1
SLEEP_DUR=$(echo "scale=2; 1 / $FRAME_RATE" | bc)

OVER=false

CURRENT_TIME=$(date +%s)
LAST_TIME=$(date +%s)

AVERAGE=0
SESSION_COUNT=0

SPRITE_DIRECTORY="b_frames"

handle_resize() {
    clear
}
trap handle_resize WINCH

# Cleanup function to run on script exit
cleanup() {
    SESSION_LENGTH=$(bc <<< "scale=2; ${TOTAL}/60")
    echo $(bc <<< "scale=2; ${TOTAL}/60") >> ttls.txt 
    tput cnorm
}
trap cleanup EXIT

computeAverage() {
    if [ -f ttls.txt ]; then
        TOTAL_VALUES=($(cat ttls.txt))
        
        SUM=0
        COUNT=0
        for VALUE in "${TOTAL_VALUES[@]}"; do
            # Ensure that VALUE is not empty and is a valid number
            if [[ -n "$VALUE" && "$VALUE" =~ ^-?[0-9]*\.?[0-9]+$ ]]; then
                # Use bc to handle decimal addition
                SUM=$(echo "$SUM + $VALUE" | bc)
                COUNT=$((COUNT + 1))
            else
                echo "Skipping invalid value: $VALUE"
            fi
        done

        SESSION_COUNT=$COUNT
        
        # Calculate the average
        if [ $COUNT -ne 0 ]; then
            AVERAGE=$(echo "scale=2; $SUM / $COUNT" | bc)
        else
            AVERAGE=0
        fi
    else
        echo "No previous TOTAL values found."
        AVERAGE=0
    fi
}



fetchCalls() {
    #api_data=$(curl -s "https://buddha-api.com/api/random")
    json_data=$(cat dhamma.json)
    total_keys=$(echo "$json_data" | jq -r 'keys | length')
    random_key=$(( (RANDOM % total_keys) + 1 ))
    echo "Random Quote:"
    echo "$random_quote"
    BY_NAME="Dhammapada"
    #QUOTE=$(echo "$api_data" | jq -r '.text')
    QUOTE=$(echo "$json_data" | jq -r --arg key "$random_key" '.[$key]')

    loc_info=$(curl -s https://ipinfo.io)
    city=$(echo "$loc_info" | jq -r '.city')
    region=$(echo "$loc_info" | jq -r '.region')

    playBell
}

fetchColor() {
  local color="$1"  # Get the first argument
  local code=""

  case "$color" in
    "red")
      code='\033[0;31m'
      ;;
    "green")
      code='\033[0;32m'
      ;;
    "yellow")
      code='\033[0;33m'
      ;;
    "blue")
      code='\033[0;34m'
      ;;
    "purple")
      code='\033[0;35m'
      ;;
    "cyan")
      code='\033[0;36m' 
      ;;
    "iwhite")
      code='\033[0;97m'  # White
      ;;
    "iblack")
      code='\033[0;90m'  # Intense Black
      ;;
    "ired")
      code='\033[0;91m'  # Intense Red
      ;;
    "igreen")
      code='\033[0;92m'  # Intense Green
      ;;
    "iyellow")
      code='\033[0;93m'  # Intense Yellow
      ;;
    "iblue")
      code='\033[0;94m'  # Intense Blue
      ;;
    "ipurple")
      code='\033[0;95m'  # Intense Purple
      ;;
    "icyan")
      code='\033[0;96m'  # Intense Cyan
      ;;
    *)
      code='\033[0m'    
      ;;
  esac

  echo "$code"  
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

playBell() {
    mpg123 bells-1-72261.mp3 > /dev/null 2>&1 &
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
    
    # calculate delta time
    CURRENT_TIME=$(date +%s)
    DELTA=$((CURRENT_TIME - LAST_TIME))
    LAST_TIME=$CURRENT_TIME

    TOTAL=$(echo "scale=2; $TOTAL + $DELTA" | bc)

    frame=$((FRAME_INDEX % 12))
    line_index=0

    local last_quote_line=444

    DISPLAY_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    #echo -e "\n[ ${COLOR}$(whoami)${RESET_COLOR} | ${COLOR}$(date +"%Y-%m-%d %H:%M:%S")${RESET_COLOR} | ${COLOR}${city}, ${region}${RESET_COLOR}  ]"
    echo -e "\n\n"

    while read -r line; do
    if [[ "$OVER" == false ]]; then
        if ((line_index == 4)); then
            echo -e "$COLOR$line$RESET_COLOR\tTotal time: $COLOR${TOTAL} seconds$RESET_COLOR"
        elif ((line_index == 6)); then
            echo -e "$COLOR$line$RESET_COLOR\t${lines[0]}"
            last_quote_line=6
        elif ((line_index == 7 && ${#lines[@]} >= 1)); then
            echo -e "$COLOR$line$RESET_COLOR\t${lines[1]}"
            last_quote_line=7
        elif ((line_index == 8 && ${#lines[@]} >= 2)); then
            echo -e "$COLOR$line$RESET_COLOR\t${lines[2]}"
            last_quote_line=8
        elif ((line_index == 9 && ${#lines[@]} >= 3)); then
            echo -e "$COLOR$line$RESET_COLOR\t${lines[3]}"
            last_quote_line=9
        elif ((line_index == 10 && ${#lines[@]} >= 4)); then
            echo -e "$COLOR$line$RESET_COLOR\t${lines[4]}"
            last_quote_line=10
        elif ((line_index == 11 && ${#lines[@]} >= 5)); then
            echo -e "$COLOR$line$RESET_COLOR\t${lines[5]}"
            last_quote_line=11
        elif ((line_index == 12 && ${#lines[@]} >= 6)); then
            echo -e "$COLOR$line$RESET_COLOR\t${lines[6]}"
            last_quote_line=12
        elif ((line_index == last_quote_line + 1)); then 
            if ((last_quote_line < 12));  then
                echo -e "$COLOR$line$RESET_COLOR\t$COLOR${BY_NAME}$RESET_COLOR"
            fi
        elif ((line_index == last_quote_line + 2)); then 
            if ((last_quote_line == 12)); then
                echo -e "$COLOR$line$RESET_COLOR\t$COLOR${BY_NAME}$RESET_COLOR"
            fi
        else
            echo -e "$COLOR$line$RESET_COLOR"
        fi
        ((line_index++))
    else 
        if ((line_index == 7)); then
            echo -e "$COLOR$line$RESET_COLOR\tSee you next time."
        elif ((line_index == 8)); then 
            echo -e "$COLOR$line$RESET_COLOR\tDon't work too hard!"
        else 
            echo -e "$COLOR$line$RESET_COLOR"
        fi
        ((line_index++))
    fi
done < "$(brew --prefix)/share/sprites/${SPRITE_DIRECTORY}/${frame}.txt"

    # FOOTER UI
    echo -e "\n"
    #echo -e "\n[ ${COLOR}Session Count${RESET_COLOR}: ${SESSION_COUNT} ] | [ ${COLOR}Average Session Length${RESET_COLOR}: ${AVERAGE}m ]" 
    

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

tput civis

# Parsing command-line options
while getopts ":t:f:c:s:" opt; do
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
        c )
            FLAG_C=true
            COLOR=$(fetchColor $OPTARG)
            echo "Option -c set with value: $COLOR"
            ;;
        s)
            SPRITE_DIRECTORY=$OPTARG
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
fetchCalls
splitQuote
#computeAverage

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
            playBell
            break
        fi
    done

else
    echo 'done'
fi
