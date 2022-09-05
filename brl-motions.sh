#!/bin/bash

# motions:
# h  left
# l  right
# w  word
# 0  beg of line
# ß  end of line
# $1  whole line (yy)

WORDDELIMS=$'() {}#[]+/\=:.,;!"&%<>|~*$\'§'     # deleimiters for words
PAIRS=('()' '{}' '[]' '""' "''" "``")           # pairs

# TODO: implement motion '%' moves to char from pair closest to cursor
# if char under cursor does not match against PAIRS (equivalent to finding
# innermost surrounding pair);
# else (if char is already pair) move to corresponding "partner"

# TODO: implement motions 'e' and 'b'

matchLeft() {
    L=$1
    until [[ "$WORDDELIMS" =~ "${READLINE_LINE:$L:1}" ]] || (( L<0 )); do
        ((L--))
    done

    echo $L
}
matchRight() {
    R=$1
    LEN=${#READLINE_LINE}
    END=$((LEN-1))
    until [[ "$WORDDELIMS" =~ "${READLINE_LINE:$R:1}" ]] || (( R>END )); do
        ((R++))
    done 

    echo $R
}

matchWords() {
    L=$(matchLeft $1)
    R=$(matchRight $1)
    if ((L==R)); then 
        ((R++))
    else
        ((L++))
    fi 
    echo $L $R
}

ACTIONID="$1"

read -n1 C
if [[ $C == "-" ]]; then 
    NEGATED=1
    read -n1 C
elif [[ $C == "+" ]]; then
    read -n1 C
fi

if [[ $C =~ [1-9] ]]; then
    INPUT="$C"
    while read -n1 C && [[ $C =~ [[:digit:]] ]]; do
        INPUT+="$C"
    done
else
    INPUT="1"
fi

MOTION="$C"
COUNT=$((INPUT+0))

# find substrings defined by given motion & count
case $MOTION in
    h)
        IDX=$((READLINE_POINT - COUNT))
        LEN=$((COUNT + 1))
        ;;
    l)
        IDX=$((READLINE_POINT))
        LEN=$((COUNT + 1))
        ;;
    w)
        if (( NEGATED!=1)); then
            read -r IDX R <<< "$(matchWords $READLINE_POINT)"
            for ((i=1; i<COUNT;i++)); do
                read -r L R <<< "$(matchWords $R)"
            done
            LEN=$((R - IDX))
        else # negated
            read -r IDX R0 <<< "$(matchWords $READLINE_POINT)"
            for ((i=1; i<COUNT;i++)); do
                read -r IDX R <<< "$(matchWords $((IDX-1)))"
            done
            LEN=$((R0 - IDX))
        fi
        ;;
    ß)
        IDX=$READLINE_POINT
        LEN=$(( ${#readline_line} - IDX ))
        ;;
    0)
        IDX=0
        LEN=$(($READLINE_POINT + 1))
        ;;
    $ACTIONID)
        IDX=0
        LEN=${#READLINE_LINE}
        ;;
esac

echo $IDX $LEN  # the requesting script is supposed to pipe this
