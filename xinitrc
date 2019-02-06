#!/bin/sh

# from /etc/skel/.xinitrc
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi


#Xorg apparently deprecated ctrl+alt+bksp, overriding
# NOTE: This now produces the following warning:
#       "Unsupported high keycode 372 for name <I372> ignored..."
setxkbmap -option terminate:ctrl_alt_bksp

#merge custom X resources file
xrdb -merge "${HOME}/.Xresources"

#fetchmail

# {{{ Display settings
if [ `xrandr | grep -c ' connected'` -eq 2 ]; then
		# xrandr --output DP-0 --primary --auto --output DVI-I-1 --auto --left-of DP-0
		xrandr --output HDMI-0 --primary --auto --output DVI-I-1 --auto --left-of HDMI-0
else
    # xrandr --output DP-0 --primary --auto
		xrandr --output HDMI-0 --primary --auto
fi;
# }}}

#start up xcompmgr
#xcompmgr -c -t-5 -l-5 -r4.2 -o.55 -f -D5 &
compton &
start-pulseaudio-x11 &
# touchpad shit, so obviously uncomment when a touchpad is present
#syndaemon -i -0.5 -t -K -R -d
#xscreensaver -nosplash &

#if [[ `xrandr | grep -c "1280x1024"` -gt 1 ]]
#then	
#fi;

#start awesome
wm_bin=${1:-awesome}
export LC_ALL=en_US.UTF-8

if [ -x ~/bin/startup ]; then
	~/bin/startup
fi;

exec ssh-agent $wm_bin
