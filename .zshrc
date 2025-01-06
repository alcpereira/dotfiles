# Check .config/zsh/ folder for specific configurations
for f in $HOME/.config/zsh/*; do
   [ -f "$f" ] && source "$f"
done

# Random stuff
unsetopt beep
export XDG_CONFIG_HOME="$HOME/.config"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export PATH=$HOME/.local/bin:$PATH

# Needs to be at the end
eval "$(starship init zsh)"

