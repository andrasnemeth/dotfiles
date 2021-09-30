#!/bin/sh

PATH=${PATH}:~/.local/bin

if [ -z "${HOSTNAME}" ]; then
    HOSTNAME=$(hostname)
fi
HOSTNAME="local"

export TERM=xterm-256color
#export POWERLINE_CONFIG_COMMAND=$(which powerline-config)

#tmux -q has-session && exec tmux -2 attach-session -d || exec tmux -2 new-session -n$USER -s$USER@$HOSTNAME

if tmux -q has-session
then
    tmux attach-session -d
else
    powerline_conf="$(pip show powerline-status | grep 'Location: ' | cut -d ' ' -f 2)/powerline/bindings/tmux/powerline.conf"
    tmux -2 new-session -d -s${USER}@${HOSTNAME}
    #tmux -2 new-window -n irssi -t 10 -d irssi
    tmux -2 source $powerline_conf
    tmux -2 attach -t ${USER}
fi
