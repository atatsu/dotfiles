# {{{ User Settings

# {{{ Environment
# Purposefully stomping over /usr/bin with ~/bin
export PATH=~/bin:~/.config/awesome/bin:$PATH:~/games/bin
if [[ -d ~/.luarocks ]] {
    PATH=$PATH:~/.luarocks/bin
    eval `luarocks path`
}

# virsh
export LIBVIRT_DEFAULT_URI=qemu:///system

# add all ruby gem bin folders to path
if [[ -d $HOME/.gem/ruby ]] {
	for dir in $HOME/.gem/ruby/*; do
		[[ -d "$dir/bin" ]] && PATH="${dir}/bin:${PATH}"
	done
}

# for luakit
export LUA_CPATH="/usr/lib/lua/5.1/?.so;$LUA_CPATH"

# {{{ Set the appropriate paths for lua5.1 and lua5.2
# }}}
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
export LESSHISTFILE="-"
export PAGER="less"
export VISUAL="nvim"
export EDITOR=$VISUAL
export BROWSER="qutebrowser"
export XTERM="xterm"
export FZF_DEFAULT_COMMAND='ag -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
#export PACMAN=pacman-color
if whence dircolors >/dev/null; then
	eval `dircolors -b`
else
	export CLICOLOR=1
fi
#source ~/.ssh_hosts
# }}}

# {{{ Manual pages
#     - colorize, since man-db fails to do so
export LESS_TERMCAP_mb=$'\E[01;31m'   # begin blinking
export LESS_TERMCAP_md=$'\E[01;31m'   # begin bold
export LESS_TERMCAP_me=$'\E[0m'       # end mode
export LESS_TERMCAP_se=$'\E[0m'       # end standout-mode
export LESS_TERMCAP_so=$'\E[1;33;40m' # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'       # end underline
export LESS_TERMCAP_us=$'\E[1;32m'    # begin underline
# }}}

# {{{ Aliases

# {{{ Auto extension
#alias -s py=$EDITOR
alias -s yml=$EDITOR
alias -s png=feh
alias -s jpg=feh
alias -s gif=feh
# }}}

# {{{ Main
if whence dircolors >/dev/null; then
	alias ls='ls -F --color=always'
else
	alias ls='ls -F'
fi
alias ll='ls -lh'
alias la='ls -a'
alias lst="tree -I 'virtualenv|node_modules|bower_components|__pycache__'"
alias ping='ping -c 4'
alias mem='free -m'
alias dh='dirs -v'
alias kvm='qemu-kvm -enable-kvm'
alias ispy='ps aux | grep python'
alias grep='grep --color'
alias sgrep='grep --color -rn --exclude-dir=.svn --exclude-dir=virtualenv --exclude-dir=node_modules'
alias sound='aplay /usr/share/sounds/alsa/Front_Center.wav'
alias fm='pcmanfm ~/'
alias ivim='ps aux | grep vim'
alias cdd='source cd.sh'
alias vimhelp='vim -c "call pathogen#helptags()|q"'
alias note='vim ~/docs/notes/`date +%Y%m%d_%H:%M`'
alias vim='~/bin/launch-vim'
alias pynvim='set_venv_nvim'
alias nvim='ssh_add_if_empty && `which -a nvim | tail -n 1`'
# }}}

# {{{ SSH
# }}}

# {{{ Pacman
#alias pacman='pacman-color'
# }}}

# {{{ git
alias st='git status'
alias br='git branch'
alias bra='git branch -a'
alias brd='git branch -d'
alias brD='git branch -D'
alias sw='git checkout'
alias swc='git checkout -b'
alias gl='git log --graph --oneline --all'
# }}}

# {{{ npm
alias npm-exec='PATH=$(npm bin):$PATH'
# }}}

# }}}

# {{{ if no keys in agent invoke `ssh-add`
ssh_add_if_empty () {
	if [[ `ssh-add -l` = "The agent has no identities." ]] {
		ssh-add
	}
}
# }}}

# {{{ virtualenv
set_venv_nvim () {
	if [[ (-e virtualenv/bin/activate) ]] {
		local cwd=`pwd`
		#VIRTUAL_ENV_PY="$cwd/virtualenv/bin/python" nvim $@
		source "$cwd/virtualenv/bin/activate" && nvim $@ && deactivate
	} else {
		nvim $@
	}
}

virt () {
    if [[ (-e virtualenv/bin/activate) ]] {
        local activate=virtualenv/bin/activate
        source ${activate}
    } else {
        echo 'no dice'
    }
}
# }}}

# {{{ LuaRocks
if [[ -x `which luarocks-5.1` ]] {
    eval `luarocks-5.1 path`
}
# }}}

# {{{ tmux playing nicely with ssh-agent
if [[ -z "$TMUX" ]] {
	# not in a tmux session

	if [[ -z "$SSH_AUTH_SOCK" ]] {
		# ssh auth variable is missing
		export SSH_AUTH_SOCK="$HOME/.ssh/.auth_socket"
	}
	if [[ ! -S "$SSH_AUTH_SOCK" ]] {
		# socket is available so create the new auth session
		eval `ssh-agent -a $SSH_AUTH_SOCK` > /dev/null 2>&1
		echo $SSH_AGENT_PID > $HOME/.ssh/.auth_pid
	}

	if [[ -z $SSH_AGENT_PID ]] {
		# agent isn't defined so recreate it from pid file
		export SSH_AGENT_PID=`cat $HOME/.ssh/.auth_pid`
	}
} else {
	# we are in a tmux session
	if [[ -z "$SSH_AUTH_SOCK" ]] {
		export SSH_AUTH_SOCK="$HOME/.ssh/.auth_socket"
	}
}
# }}}

# {{{ Keybindings
bindkey -v
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
bindkey "\e[3~" delete-char
bindkey "\e[2~" quoted-insert
bindkey "\e[5C" forward-word
bindkey "\eOc" emacs-forward-word
bindkey "\e[5D" backward-word
bindkey "\eOd" emacs-backward-word
bindkey "\e\e[C" forward-word
bindkey "\e\e[D" backward-word
bindkey "^H" backward-delete-word
bindkey "^R" history-incremental-search-backward
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
# }}}

# }}}

# {{{ ZSH Settings
# Prompt requirements
setopt extended_glob prompt_subst
setopt autopushd pushdminus pushdsilent pushdtohome
autoload colors zsh/terminfo

# New style completion system
autoload -U compinit; compinit
#  * List of completers to use
zstyle ":completion:*" completer _complete _match _approximate
#  * Allow approximate
zstyle ":completion:*:match:*" original only
zstyle ":completion:*:approximate:*" max-errors 1 numeric
#  * Selection prompt as menu
zstyle ":completion:*" menu select=1
#  * Menu selection for PID completion
zstyle ":completion:*:*:kill:*" menu yes select
zstyle ":completion:*:kill:*" force-list always
zstyle ":completion:*:processes" command "ps -au$USER"
zstyle ":completion:*:*:kill:*:processes" list-colors "=(#b) #([0-9]#)*=0=01;32"
#  * Don't select parent dir on cd
zstyle ":completion:*:cd:*" ignore-parents parent pwd
#  * Complete with colors
zstyle ":completion:*" list-colors ""
#  * type a directory's name to cd to it
#compctl -/ cd
# }}}

# {{{ fzf overrides
_fzf_compgen_path() {
	ag -g "" "$1"
}
# }}}

# {{{ Prompt Settings
function prompt_char {
    git branch >/dev/null 2>/dev/null && echo '±' && return
    echo '○'
}

parse_git_branch () {
    git branch 2> /dev/null | grep "*" | sed -e 's/* \(.*\)/ %F{green}(%F{yellow}\1%F{green})/g'
}

function precmd {
    ###
    # terminal width to one less than the actual width for lineup
    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))
    ###
    # truncate the path if it's too long
    PR_FILLBAR=""
    PR_PWDLEN=""
    local promptsize=${#${(%):---(%n@%m:%l)---()--}}
    local pwdsize=${#${(%):-%~}}
    if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
	((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
        PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
    fi
}
###
# set the window title in screen to the currently running program
setopt extended_glob
function preexec () {
    if [[ "$TERM" == "screen-256color" ]]; then
        local CMD=${1[(wr)^(*=*|sudo|-*)]}
        echo -n "\ek$CMD\e\\"
    fi
}
function setprompt () {
    ###
    # need this so the prompt will work
    setopt prompt_subst
    ###
    # try to use colors
    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
        colors
    fi
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
    done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"
    ###
    # try to use extended characters to look nicer
    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    PR_HBAR=${altchar[q]:--}
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_LRCORNER=${altchar[j]:--}
    PR_URCORNER=${altchar[k]:--}
    ###
    # set titlebar text on a terminal emulator
    case $TERM in
	rxvt*)
	    PR_TITLEBAR=$'%{\e]0;%(!.*ROOT* | .)$(prompt_char)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
	    ;;
	screen*)
            PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.*ROOT* |.)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
            # ensure SSH agent is still usable after an X restart
            SSH_AUTH_SOCK=`find /tmp/gpg-* -name S.gpg-agent.ssh`
	    ;;
	*)
            PR_TITLEBAR=''
	    ;;
    esac
    ###
    # Linux console and Emacs ansi-term get simpler prompts, the rest have:
    #   - (user@hostname:tty)--($PWD) and an exit code of the last command
    #   - right hand prompt which makes room if the command line grows past it
    #   - PS2 continuation prompt to match PS1 in color
    case $TERM in
        dumb)
            unsetopt zle
            PROMPT='%n@%m:%~%% '
            ;;
	eterm-color)
            PROMPT='$PR_YELLOW%n$PR_WHITE:%~$PR_NO_COLOUR%% '
	    ;;
        linux)
            # zenburn for the Linux console
            echo -en "\e]P01e2320" #zen-black (norm. black)
            echo -en "\e]P8709080" #zen-bright-black (norm. darkgrey)
            echo -en "\e]P1705050" #zen-red (norm. darkred)
            echo -en "\e]P9dca3a3" #zen-bright-red (norm. red)
            echo -en "\e]P260b48a" #zen-green (norm. darkgreen)
            echo -en "\e]PAc3bf9f" #zen-bright-green (norm. green)
            echo -en "\e]P3dfaf8f" #zen-yellow (norm. brown)
            echo -en "\e]PBf0dfaf" #zen-bright-yellow (norm. yellow)
            echo -en "\e]P4506070" #zen-blue (norm. darkblue)
            echo -en "\e]PC94bff3" #zen-bright-blue (norm. blue)
            echo -en "\e]P5dc8cc3" #zen-purple (norm. darkmagenta)
            echo -en "\e]PDec93d3" #zen-bright-purple (norm. magenta)
            echo -en "\e]P68cd0d3" #zen-cyan (norm. darkcyan)
            echo -en "\e]PE93e0e3" #zen-bright-cyan (norm. cyan)
            echo -en "\e]P7dcdccc" #zen-white (norm. lightgrey)
            echo -en "\e]PFffffff" #zen-bright-white (norm. white)
            # avoid 'artefacts'
            #clear
            #
            PROMPT='$PR_GREEN%n@%m$PR_WHITE:$PR_YELLOW%l$PR_WHITE:$PR_RED%~$PR_YELLOW%%$PR_NO_COLOUR '
            ;;
	*)
            PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
$PR_GREEN$PR_SHIFT_IN$PR_ULCORNER$PR_GREEN$PR_HBAR$PR_SHIFT_OUT(\
$PR_GREEN%(!.%SROOT%s.%n)$PR_GREEN@%m$PR_WHITE:$PR_YELLOW%l\
$PR_GREEN)$PR_SHIFT_IN$PR_HBAR$PR_GREEN$PR_HBAR${(e)PR_FILLBAR}$PR_GREEN$PR_HBAR$PR_SHIFT_OUT(\
$PR_RED%$PR_PWDLEN<...<%~%<<$PR_GREEN)$PR_SHIFT_IN$PR_HBAR$PR_GREEN$PR_URCORNER$PR_SHIFT_OUT\

$PR_GREEN$PR_SHIFT_IN$PR_LLCORNER$PR_GREEN$PR_HBAR$PR_SHIFT_OUT(\
%(?..$PR_RED%?$PR_WHITE:)%(!.$PR_RED.$PR_YELLOW)%#$PR_GREEN)$PR_NO_COLOUR '

RPROMPT=' $PR_GREEN$(parse_git_branch)$PR_GREEN$PR_SHIFT_IN$PR_HBAR$PR_GREEN$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'

            PS2='$PR_GREEN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_GREEN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT(\
$PR_YELLOW%_$PR_GREEN)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_GREEN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_NO_COLOUR '
            ;;
    esac
}

# Prompt init
setprompt
# }}}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# nix 
[ -f /usr/share/nvm/init-nvm.sh ] && source /usr/share/nvm/init-nvm.sh
# mac
export NVM_DIR="${HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
