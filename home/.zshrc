source /home/nrw/.zim/templates/zshrc

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

# fixing word delimiters
autoload -U select-word-style
select-word-style bash
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# 'workaround' for disappearing cursor on moving backwards
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor brackets pattern)
ZSH_HIGHLIGHT_STYLES[cursor]=bold
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

# ===== Basics
setopt no_beep # don't beep on error
setopt interactive_comments # Allow comments even in interactive shells (especially for Muness)

# ===== Changing Directories
setopt auto_cd # If you type foo, and it isn't a command, and it is a directory in your cdpath, go there
setopt cdablevarS # if argument to cd is the name of a parameter whose value is a valid directory, it will become the current directory
setopt pushd_ignore_dups # don't push multiple copies of the same directory onto the directory stack

# ===== Expansion and Globbing
setopt extended_glob # treat #, ~, and ^ as part of patterns for filename generation

# ===== History
setopt append_history # Allow multiple terminal sessions to all append to one zsh command history
setopt extended_history # save timestamp of command and duration
setopt inc_append_history # Add comamnds as they are typed, don't wait until shell exit
setopt hist_expire_dups_first # when trimming history, lose oldest duplicates first
setopt hist_ignore_dups # Do not write events to history that are duplicates of previous events
setopt hist_ignore_space # remove command line from history list when first character on the line is a space
setopt hist_find_no_dups # When searching history don't display results already cycled through twice
setopt hist_reduce_blanks # Remove extra blanks from each command line being added to history
setopt hist_verify # don't execute, just expand history
setopt share_history # imports new commands and appends typed commands to history

# ===== Completion
setopt always_to_end # When completing from the middle of a word, move the cursor to the end of the word
setopt auto_menu # show completion menu on successive tab press. needs unsetop menu_complete to work
setopt auto_name_dirs # any parameter that is set to the absolute name of a directory immediately becomes a name for that directory
setopt complete_in_word # Allow completion from within a word/phrase

unsetopt menu_complete # do not autoselect the first completion entry

# ===== Correction
#setopt correct # spelling correction for commands
#setopt correctall # spelling correction for arguments

# ===== Prompt
setopt prompt_subst # Enable parameter expansion, command substitution, and arithmetic expansion in the prompt
setopt transient_rprompt # only show the rprompt on the current prompt

# ===== Scripts and Functions
setopt multios # perform implicit tees or cats when multiple redirections are attempted
