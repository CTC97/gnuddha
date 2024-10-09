#!/bin/bash

# Color codes
RED='\033[31m'
CYAN='\033[0;36m'
NC='\033[0m'
TOTAL=0

# Flags and variables
FLAG_T=true
SESSION_TIME=${SESSION_TIME:-5}

BY_NAME=""
QUOTE=""

FLAG_F=false
FRAME_RATE=24

FLAG_C=false
COLOR=${COLOR:-"\033[0m"}
RESET_COLOR="\033[0m"

FRAME_UP=1
FRAME_INDEX=1
SLEEP_DUR=$(echo "scale=2; 1 / $FRAME_RATE" | bc)

OVER=false

CURRENT_TIME=$(date +%s)
LAST_TIME=$(date +%s)

SPRITE_DIRECTORY=${SPRITE_DIRECTORY:-"1"}
BELL_DIRECTORY=${BELL_DIRECTORY:-"3"}

STORE_NEW_DEFAULTS=false

DIRECTORY=$(mktemp -d)
mkdir "${DIRECTORY}/res"
cp -r $(brew --prefix gnuddha)/share/gnuddha/* "${DIRECTORY}/res"

#for local development
# DIRECTORY="."

handle_resize() {
    clear
}
trap handle_resize WINCH

# Cleanup function to run on script exit
cleanup() {
    SESSION_LENGTH=$(bc <<< "scale=2; ${TOTAL}/60")
    tput cnorm

if [ "$STORE_NEW_DEFAULTS" = true ]; then
  cat > "$(brew --prefix gnuddha)/share/gnuddha/config.cfg" <<EOL
# DEFAULT CONFIGURATION
SESSION_TIME="${SESSION_TIME}"
SPRITE_DIRECTORY="${SPRITE_DIRECTORY}"
BELL_DIRECTORY="${BELL_DIRECTORY}"
COLOR="${COLOR}"
EOL
fi
}
trap cleanup EXIT

fetchDefaults() {
    CONFIG_FILE="$(brew --prefix gnuddha)/share/gnuddha/config.cfg"
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
}

fetchCalls() {
    json_data=$(cat "${DIRECTORY}/res/docs/dhamma.json")
    total_keys=$(echo "$json_data" | jq -r 'keys | length')
    random_key=$(( RANDOM % total_keys ))
    QUOTE=$(echo "$json_data" | jq -r --arg key "$random_key" '.[$key].quote')
    BY_NAME=$(echo "$json_data" | jq -r --arg key "$random_key" '.[$key].source')

    if [ -z "$QUOTE" ] || [ "$QUOTE" == "null" ]; then
        QUOTE="Breathe."
        BY_NAME=""
    fi

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
    "clay")
      code='\033[38;5;217m'
      ;;
    "pink")
      code='\033[38;5;205m'
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
        length_test=$(( ${#result} + ${#word} + 1 ))

        if (( length_test > max_length )); then
            lines+=("$result")
            echo -e "\t\t${result}"
            result="$word"
        else
            if [[ -n $result ]]; then
                result+=$' '$word
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
    mpg123 "${DIRECTORY}/res/sounds/${BELL_DIRECTORY}.mp3" > /dev/null 2>&1 &
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
    echo -e "\n\n"

    while read -r line; do
    if [[ "$OVER" == false ]]; then
        if ((line_index == 4)); then
            if (( TOTAL >= 60 )); then
                MINUTES=$(( TOTAL / 60 ))
                SECONDS=$(( TOTAL % 60 ))
                echo -e "$COLOR$line$RESET_COLOR\tTotal time: $COLOR${MINUTES}m ${SECONDS}s$RESET_COLOR"
            else
                echo -e "$COLOR$line$RESET_COLOR\tTotal time: $COLOR${TOTAL} seconds$RESET_COLOR"
            fi
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
done < "${DIRECTORY}/res/sprites/${SPRITE_DIRECTORY}/${frame}.txt"

    # FOOTER UI
    echo -e "\n"


    sleep "$SLEEP_DUR"
    if [[ "$OVER" == false ]]; then
        clear
    fi
}

usage() {
    echo "Usage: $0 [-t time_in_minutes]"
    exit 1
}

tput civis

fetchDefaults

while getopts ":t:f:c:s:b:d" opt; do
    case ${opt} in
        t )
            FLAG_T=true
            SESSION_TIME=$OPTARG
            ;;
        f )
            FLAG_F=true
            FRAME_RATE=$OPTARG
            ;;
        c )
            FLAG_C=true
            COLOR=$(fetchColor $OPTARG)
            ;;
        s)
            SPRITE_DIRECTORY=$OPTARG
            ;;
        b)
            BELL_DIRECTORY=$OPTARG
            ;;
        d)
            STORE_NEW_DEFAULTS=true
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

fetchCalls
splitQuote

if [ "$FLAG_F" = true ]; then
    echo FLAGFFRUE
    echo "$FRAME_RATE"
fi


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
fi
