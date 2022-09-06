#!/bin/bash

brl-input-buffer()
{
    xclip -i -selection clipboard
}

brl-output-buffer()
{
    xclip -o -selection clipboard
}

brl-yank()
{
    read -r IDX LEN <<< "$(./brl-motions.sh y)"
    brl-input-buffer <<< "${READLINE_LINE:$IDX:$LEN}"
}

brl-cut()
{
    read -r IDX LEN <<< "$(./brl-motions.sh d)"
    brl-input-buffer <<< "${READLINE_LINE:$IDX:$LEN}"
    READLINE_LINE="${READLINE_LINE::$IDX}${READLINE_LINE:$((IDX+LEN))}"
    READLINE_POINT=$IDX
}

brl-paste()
{
    PASTEBUFFER="$(brl-output-buffer)"
    READLINE_LINE="${READLINE_LINE::$((READLINE_POINT+1))}${PASTEBUFFER}${READLINE_LINE:$((READLINE_POINT+1))}"
    READLINE_POINT=$((${READLINE_POINT} + ${#PASTEBUFFER}))
}
