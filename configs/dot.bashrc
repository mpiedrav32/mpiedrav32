#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

export EDITOR=vim

export MANWIDTH=80

[ -f "/home/mpiedrav/.ghcup/env" ] && source "/home/mpiedrav/.ghcup/env" # ghcup-env

eval $(opam env)
