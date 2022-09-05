#!/bin/bash

brl-yank()
{
    read -r IDX LEN <<< "$(./brl-motions.sh y)"
    xclip -i -selection clipboard <<< "${READLINE_LINE:$IDX:$LEN}"
}

brl-cut()
{
    read -r IDX LEN <<< "$(./brl-motions.sh d)"
    xclip -i -selection clipboard <<< "${READLINE_LINE:$IDX:$LEN}"
    READLINE_LINE="${READLINE_LINE::$IDX}${READLINE_LINE:$((IDX+LEN))}"
}

brl-paste()
{
    PASTEBUFFER="$(xclip -o -selection clipboard)"
    READLINE_LINE="${READLINE_LINE::$((READLINE_POINT+1))}${PASTEBUFFER}${READLINE_LINE:$((READLINE_POINT+1))}"
    READLINE_POINT=$((${READLINE_POINT} + ${#PASTEBUFFER}))
}
