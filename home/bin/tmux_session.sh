#!/bin/sh

export TERM=xterm-256color
#export POWERLINE_CONFIG_COMMAND=$(which powerline-config)

#tmux -q has-session && exec tmux -2 attach-session -d || exec tmux -2 new-session -n$USER -s$USER@$HOSTNAME

if tmux -q has-session
then
    tmux attach-session -d
else
    tmux -2 new-session -d -n${USER} -s${USER}@${HOSTNAME}
    tmux -2 new-window -n irssi -t 10 -d irssi
    tmux -2 source /usr/share/tmux/powerline.conf # hack
    tmux -2 attach -t ${USER}
fi

