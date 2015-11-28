source ~/.zprezto/runcoms/zshrc

##
## alias
alias wpa="sudo wpa_supplicant -B -i enp0s25 -c /etc/wpa_supplicant/wpa_supplicant.conf"
alias plantuml="java -jar ~/tools/plantuml.jar"

##
## keybinding
bindkey "\e[3;5~" delete-word
bindkey "^H" backward-delete-word

zstyle ':completion:*' use-ip true
#zstyle -e ':completion::*:*:*:hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

##
##
local_zsh_source="/mnt/local/dotfiles/zshrc.sh"
if [ -f "$local_zsh_source" ]; then
    source "$local_zsh_source"
fi

function countdown() {
  date1=$((`date +%s` + $1));
  while [ "$date1" -ne `date +%s` ]; do
    echo -ne "$(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
    sleep 0.1
  done
}

function stopwatch() {
  date1=`date +%s`;
   while true; do
    echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r";
    sleep 0.1
   done
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
