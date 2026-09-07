#ddev-generated
# This file is managed by ddev-zsh.
# Place customizations in:
#   ~/.ddev/homeadditions/.zshrc.global
#   <project>/.ddev/homeadditions/.zshrc.project

[[ -o interactive ]] || return

# Shared persistent storage for shell tools and Zsh history.
export DDEV_ZSH_HOME=/mnt/ddev-zsh

mkdir -p "$DDEV_ZSH_HOME"

# ------------------------------------------------------------------
# Tool state locations
# ------------------------------------------------------------------

# Antidote plugin cache directory and generated static bundle.
export ANTIDOTE_HOME="$DDEV_ZSH_HOME/antidote"
zstyle ':antidote:static' file "$ANTIDOTE_HOME/plugins.zsh"

# Oh My Zsh installation and cache directories.
export ZSH=/usr/local/share/oh-my-zsh
export ZSH_CACHE_DIR="$DDEV_ZSH_HOME/oh-my-zsh/cache"

# Starship cache directory.
export STARSHIP_CACHE="$DDEV_ZSH_HOME/starship/cache"

# ------------------------------------------------------------------
# History configuration
# ------------------------------------------------------------------

export HISTFILE="$DDEV_ZSH_HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

# ------------------------------------------------------------------
# User configuration
# ------------------------------------------------------------------

[[ -r "${HOME}/.zshrc.global" ]] \
  && source "${HOME}/.zshrc.global"

[[ -r "${HOME}/.zshrc.project" ]] \
  && source "${HOME}/.zshrc.project"
