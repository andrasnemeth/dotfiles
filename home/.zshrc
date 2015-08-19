source ~/.zprezto/runcoms/zshrc

alias wpa="sudo wpa_supplicant -B -i enp0s25 -c /etc/wpa_supplicant/wpa_supplicant.conf"

local_zsh_source="/mnt/local/dotfiles/zshrc.sh"
if [ -f "$local_zsh_source" ]; then
    source "$local_zsh_source"
fi
