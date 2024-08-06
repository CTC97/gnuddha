# GNUddha - Bash Meditation

<img src="content/Screenshot 2024-08-06 at 7.12.52 PM.png" alt="alt text" width="500"/>

## Overview

Bringing meditation to coders - people who need it, and often never turn to it.

Usage: ./gnuddha.sh -t [session length in minutes]

## Arguments
- session length: ```-t [length in minutes]```
- frame rate: ```-f [fps]```
- highlight color: ```-c [color (see list below)]```
    - available colors: ```[red, green, yellow, blue, purple, cyan, iwhite, iblack, ired, igreen, iyellow, iblue, ipurple, icyan]```

## Requirements

- `bash` (tested with Bash 4.x)
- `curl` for fetching data from the API
- `jq` for processing JSON data
- `bc` for basic arithmetic operations