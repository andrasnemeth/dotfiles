source ~/.zprezto/runcoms/zshrc

##
## alias
alias wpa="sudo wpa_supplicant -B -i enp0s25 -c /etc/wpa_supplicant/wpa_supplicant.conf"
alias plantuml="java -jar ~/tools/plantuml.jar"

##
## keybinding
bindkey "\e[3;5~" delete-word
bindkey "^H" backward-delete-word

##
##
local_zsh_source="/mnt/local/dotfiles/zshrc.sh"
if [ -f "$local_zsh_source" ]; then
    source "$local_zsh_source"
fi


