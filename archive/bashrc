set -o vi
export PS1="\u@laptop:\w\[$(tput sgr0)\]$ "
export PROMPT_COMMAND='if [ "$(id -u)" -ne 0 ]; then echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history 1)" >> /Users/jwong/logs/bash-history-$(date "+%Y-%m-%d").log; fi'
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_152.jdk/Contents/Home/
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH="/usr/local/munki:$PATH"
export PATH="/usr/local/anaconda3/bin:$PATH"
export PATH="$HOME/bin:$PATH"
if [ -f $HOME/.bashrc_private ]; then
	. $HOME/.bashrc_private
fi

. ~/.nix-profile/etc/profile.d/nix.sh

# [ -s "$HOME/dotfiles/scm_breeze/scm_breeze.sh" ] && source "$HOME/dotfiles/scm_breeze/scm_breeze.sh"
