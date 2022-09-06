#!/bin/bash

# motions:
# h     left
# l     right
# w     whole word
# 0     beginning of line
# ß     end of line
# $1    whole line (e.g. yy, dd)
# b     beginning of word
# e     end of word

WORDDELIMS=$'() {}\#[]+/\=:.,;!"&%<>|~*$\'§'     # deleimiters for words
PAIRS=('()' '{}' '[]' '""' "''" "``")           # pairs

# TODO: implement motion '%' moves to char from pair closest to cursor
# if char under cursor does not match against PAIRS (equivalent to finding
# innermost surrounding pair);
# else (if char is already pair) move to corresponding "partner"

matchLeft() {
    IFS='#' read -r L MATCH <<< "$@"
    until [[ "$MATCH" =~ "${READLINE_LINE:$L:1}" ]] || (( L<0 )); do
        ((L--))
    done

    echo $L
}
matchRight() {
    IFS='#' read -r R MATCH <<< "$@"
    LEN=${#READLINE_LINE}
    END=$((LEN-1))
    until [[ "$MATCH" =~ "${READLINE_LINE:$R:1}" ]] || (( R>END )); do
        ((R++))
    done 

    echo $R
}

matchBeginning() {
    L=$1
    ((L--))                 # look at pos before cursor
    # if this char is a worddelim we are already at beginning of word
    if (( $(matchLeft $L#$WORDDELIMS) == $L )); then
        ((L--))             # thus move left
    fi
    # find next worddelim to the left
    L=$(matchLeft $L#$WORDDELIMS)
    echo $((L+1))
}
matchEnd() {
    R=$1
    ((R++))                 # look at pos after cursor
    if (( $(matchLeft $R#$WORDDELIMS) == $R )); then
        ((R++))             # move right
    fi
    R=$(matchRight $R#$WORDDELIMS)
    echo $((R-1))
}

matchWords() {
    L=$(matchLeft $1#$WORDDELIMS)
    R=$(matchRight $1#$WORDDELIMS)
    if ((L==R)); then 
        ((R++))
    else
        ((L++))
    fi 
    echo $L $R
}


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

ACTIONKEY="$1"
MOTION="$C"
COUNT=$((INPUT+0))

# find substrings defined by given motion & count
case $MOTION in
    h)
        IDX=$((READLINE_POINT - COUNT))
        LEN=$COUNT
        ;;

    l)
        IDX=$READLINE_POINT
        LEN=$COUNT
        ;;

    w)
        read -r IDX R <<< "$(matchWords $READLINE_POINT)"
        if (( NEGATED!=1)); then
            for ((i=1; i<COUNT;i++)); do
                read -r TMP R <<< "$(matchWords $R)"
            done
        else
            for ((i=1; i<COUNT;i++)); do
                read -r IDX TMP <<< "$(matchWords $((IDX-1)))"
            done
        fi
        LEN=$((R - IDX))
        ;;

    ß)
        IDX=$READLINE_POINT
        LEN=$((${#READLINE_LINE} - IDX))
        ;;

    0)
        IDX=0
        LEN=$READLINE_POINT
        ;;

    $ACTIONKEY)
        IDX=0
        LEN=${#READLINE_LINE}
        ;;

    b)
        IDX=$(matchBeginning $READLINE_POINT)
        for ((i=1; i<COUNT; i++)); do
            IDX=$(matchBeginning $IDX)
        done
        LEN=$((READLINE_POINT - IDX))
        ;;

    e)
        END=$(matchEnd $READLINE_POINT)
        for ((i=1; i<COUNT; i++)); do
            END=$(matchEnd $END)
        done
        IDX=$READLINE_POINT
        LEN=$((END - IDX + 1))
        ;;
esac

echo $IDX $LEN  # the requesting script is supposed to pipe this
