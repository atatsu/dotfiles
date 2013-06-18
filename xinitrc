#!/bin/sh

# from /etc/skel/.xinitrc
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# {{{ Display settings
if [[ `xrandr | grep -c "1280x1024"` -gt 1 ]]; then
    xrandr --output DVI-I-2 --primary --mode 1680x1050 --output DVI-I-3 --auto --right-of DVI-I-2
else
    xrandr --output DVI-1 --primary --mode 1680x1050
fi;
# }}}

#Xorg apparently deprecated ctrl+alt+bksp, overriding
setxkbmap -option terminate:ctrl_alt_bksp

#merge custom X resources file
xrdb -merge "${HOME}/.Xresources"

#fetchmail

#start up xcompmgr
xcompmgr -c -t-5 -l-5 -r4.2 -o.55 -f -D5 &
#xscreensaver -nosplash &

#if [[ `xrandr | grep -c "1280x1024"` -gt 1 ]]
#then	
#fi;

#start awesome
wm_bin="$1"
if [[ -z $wm_bin ]] ; then
    wm_bin="i3"
fi;
eval $(cat ~/.fehbg)
exec ssh-agent ${wm_bin}
