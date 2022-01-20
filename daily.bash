#!/usr/bin/bash

NC='\033[0m'
ARG='\033[0;31m' # red
TXT='\033[0;32m' # green, or 1;32m for light green
SYM='\u2192' # right arrow

DAILY_DIR=$(Rscript -e "calcurseR:::cc_dir()")
DAILY_DIR=$(echo $DAILY_DIR | sed 's/^\[1\]//;s/\"//g')

if [ "$1" == "" ]; then
    Rscript -e "calcurseR::cc_update_daily()"
elif [ "$1" == "help" ]; then
    echo -e "${SYM} ${ARG}no arguments${NC}    : ${TXT}update daily task list from calendar.${NC}"
    echo -e "${SYM} ${ARG}help${NC}            : ${TXT}display these help messages.${NC}"
    echo -e "${SYM} ${ARG}notes${NC}           : ${TXT}update daily task list from todo notes.${NC}"
    echo -e "${SYM} ${ARG}open/edit${NC}       : ${TXT}open daily task list with vim.${NC}"
    echo -e "${SYM} ${ARG}st${NC}              : ${TXT}git status of 'daily.md'.${NC}"
    echo -e "${SYM} ${ARG}diff${NC}            : ${TXT}git diff of 'daily.md'.${NC}"
elif [ "$1" == "notes" ]; then
    Rscript -e "calcurseR::cc_update_notes()"
elif [ "$1" == "open" ] || [ "$1" == "edit" ]; then
    Rscript -e "calcurseR::cc_edit_daily()"
elif [ "$1" == "st" ]; then
    git -C $DAILY_DIR st
elif [ "$1" == "diff" ]; then
    git -C $DAILY_DIR diff daily.md
else
    echo -e "daily on accepts 'notes'; see 'daily --help' for help"
fi
