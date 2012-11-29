#!/bin/sh

STATUS=`~/.config/awesome/scripts/mpd.awk`
TITLE=`mpc | head -n 1`
MTIME=`mpc | head -n 2 | tail -n 1 | awk '{print $3}'`

if [[ -n `mpc | grep "random: on"` ]]; then
    RANDOMPLAY="z"
fi
if [[ -n `mpc | grep "repeat: on"` ]]; then
    REPEATPLAY="r"
fi
if [[ -n `mpc | grep "single: on"` ]]; then
    SINGLEPLAY="s"
fi
if [ -n $REPEATPLAY$RANDOMPLAY ]; then
    FLAGS="[$REPEATPLAY$RANDOMPLAY$SINGLEPLAY]"
fi

CURR=`mpc current`
if [ -z "$CURR" ]; then
	TITLE="mpd `mpd --version | head -n 1 | awk '{print $6}'`"
	MTIME="stopped"
fi

echo -n "$STATUS|$TITLE|$MTIME $FLAGS"
