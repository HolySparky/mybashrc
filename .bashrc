[[ $- != *i* ]] && return

export EDITOR='vim'

export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

export FORCE='yes'

bind Space:magic-space

HISTCONTROL=ignoredups:ignorespace
HISTSIZE=1000
HISTFILESIZE=2000
PROMPT_COMMAND='history -a'

shopt -s histappend
shopt -s checkwinsize
shopt -s globstar

if type -P tput &>/dev/null && tput setaf 1 &>/dev/null; then
    color_prompt=yes
else
    color_prompt=
fi

__repo () {
    branch=$(type __git_ps1 &>/dev/null && __git_ps1 | sed -e "s/^ (//" -e "s/)$//")
    if [ "$branch" != "" ]; then
        vcs=git
    else
        branch=$(type -P hg &>/dev/null && hg branch 2>/dev/null)
        if [ "$branch" != "" ]; then
            vcs=hg
        elif [ -e .bzr ]; then
            vcs=bzr
        elif [ -e .svn ]; then
            vcs=svn
        else
            vcs=
        fi
    fi
    if [ "$vcs" != "" ]; then
        if [ "$branch" != "" ]; then
            repo=$vcs:$branch
        else
            repo=$vcs
        fi
        echo -n "($repo)"
    fi
    return 0
}

if [ "$color_prompt" = yes ]; then
    PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[01;33m\]$(__repo)\[\e[00m\]\$ '
else
    PS1='\u@\h:\w$(__repo)\$ '
fi
unset color_prompt

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

if type -P dircolors &>/dev/null; then
    [ -r ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

which () {
    (alias; declare -f) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot $@
}
export -f which

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Workaround for the vte bug
parent=$(basename $(cat /proc/$(grep PPid /proc/$$/status | grep -o '[0-9]\+')/cmdline))
[ "x$parent" = "xTerminal" -o "x$parent" = "xxterm" ] && export TERM=xterm-256color
unset parent
