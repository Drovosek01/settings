zstyle ':completion:*' menu select

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


autoload -Uz compinit promptinit
compinit
promptinit

#
# SETOPT
#

# do not store duplications
setopt HIST_IGNORE_DUPS
# removes blank lines from history
setopt HIST_REDUCE_BLANKS

setopt CORRECT
setopt CORRECT_ALL

#
# ALIASES
#

alias ll='ls -al'
alias cds='codesign --force --deep --sign -'
