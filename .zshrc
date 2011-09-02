if [[ -s /Users/acanals/.rvm/scripts/rvm ]] ; then source /Users/acanals/.rvm/scripts/rvm ; fi
export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:~/android-sdk-mac/tools:/usr/local/bin/rubinius/1.2/bin:/Users/acanals/bin:$PATH"

# 
# GIT
# 
alias gc="git commit -m $1"
alias gca="git add -A; git commit -m $1"
alias gcap=git_add_all_commit_and_push
alias gs='git status'
alias gf='git fetch'
alias gm='git merge origin'
alias gp='git push'
alias gpl='git pull'
alias gpom="git pull origin master"

function git_add_all_commit_and_push () {
  git add -A;
  git commit -m "$1";
  git push;
}

# SVN
alias ss="svn status"
alias sup="svn update"
alias sad="svn add"
alias sc="svn commit -m $1"
alias sco="svn checkout"
alias svlog="svn log -l $1"
alias sgrep="grep -iIr --exclude='*\.svn*'"

autoload -U colors
colors

alias work="cd ~/Projects/"

function parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

setopt prompt_subst
PROMPT='
[$(whoami)@$(hostname)][$(~/.rvm/bin/rvm-prompt i v g)]%{$fg_bold[green]%}$(parse_git_branch)%{$reset_color%} 
%~ '

# Set RPROMPT to have info show up on the right, too.
#RPROMPT="\$(~/.rvm/bin/rvm-prompt) $RPROMPT"

#############################
# Other Options

bindkey -v

# setopt PRINT_EXIT_VALUE

setopt CORRECT
setopt CORRECTALL

setopt hist_ignore_dups     # ignore duplication command history list
setopt share_history        # share command history data
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY # write history only when closing
setopt EXTENDED_HISTORY # add more info

# Other tabbing options
# setopt NO_AUTO_MENU
# setopt BASH_AUTO_LIST

#############################
# Variables

# Quote pasted URLs
autoload url-quote-magic
zle -N self-insert url-quote-magic

HISTFILE=~/.zsh_history
SAVEHIST=10000
HISTSIZE=10000

REPORTTIME=10 # Show elapsed time if command took more than X seconds
LISTMAX=0 # ask to complete if top of list would scroll off screen

# Load completions for Ruby, Git, etc.
autoload compinit
compinit

# Make CTRL-W delete after other chars, not just spaces
WORDCHARS=${WORDCHARS//[&=\/;\!#%\{]}

bindkey -e

autoload colors; colors

# The variables are wrapped in %{%}. This should be the case for every
# variable that does not contain space.
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
  eval PR_$COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
  eval PR_BOLD_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done

eval RESET='$reset_color'
export PR_RED PR_GREEN PR_YELLOW PR_BLUE PR_WHITE PR_BLACK
export PR_BOLD_RED PR_BOLD_GREEN PR_BOLD_YELLOW PR_BOLD_BLUE 
export PR_BOLD_WHITE PR_BOLD_BLACK

# Clear LSCOLORS
unset LSCOLORS

# Main change, you can see directories on a dark background
#expor tLSCOLORS=gxfxcxdxbxegedabagacad

export CLICOLOR=1
export LS_COLORS=exfxcxdxbxegedabagacad

if [ "$TERM" != "dumb" ] && [ -x /usr/bin/dircolors ]; then
  alias ls='ls --color=auto'
  eval `dircolors`
fi

# =============================
# = Directory save and recall =
# =============================

# I got the following from, and mod'd it: http://www.macosxhints.com/article.php?story=20020716005123797
#    The following aliases (save & show) are for saving frequently used directories
#    You can save a directory using an abbreviation of your choosing. Eg. save ms
#    You can subsequently move to one of the saved directories by using cd with
#    the abbreviation you chose. Eg. cd ms  (Note that no '$' is necessary.)

# if ~/.dirs file doesn't exist, create it
if [ ! -f ~/.dirs ]; then
  touch ~/.dirs
fi

alias show='cat ~/.dirs'
alias showdirs="cat ~/.dirs | ruby -e \"puts STDIN.read.split(10.chr).sort.map{|x| x.gsub(/^(.+)=.+$/, '\\1')}.join(', ')\""
save (){
  local usage
  usage="Usage: save shortcut_name"
  if [ $# -lt 1 ]; then
    echo "$usage"
    return 1
  fi
  if [ $# -gt 1 ]; then
    echo "Too many arguments!"
    echo "$usage"
    return 1
  fi
  if [ -z $(echo $@ | grep --color=never "^[a-zA-Z]\w*$") ]; then
    echo "Bad argument! $@ is not a valid alias!"
    return 1
  fi
  if [ $(cat ~/.dirs | grep --color=never "^$@=" | wc -l) -gt 0 ]; then
    echo -n "That alias is already set to: "
    echo $(cat ~/.dirs | awk "/^$@=/" | sed "s/^$@=//" | tail -1)
    read -p "Do you want to overwrite it? (y/n) " answer
    if [ ! "$answer" == "y" -a ! "$answer" == "yes" ]; then
      return 0
    else
      # backup just in case
      cp ~/.dirs ~/.dirs.bak
      # delete existing version(s) of this alias
      cat ~/.dirs | sed "s/^$@=.*//" | sed '/^$/d' > ~/.dirs.tmp
      mv ~/.dirs.tmp ~/.dirs
    fi
  fi
  echo "$@"=\"`pwd`\" >> ~/.dirs
  source ~/.dirs
  echo "Directory shortcuts:" `showdirs`
}
source ~/.dirs  # Initialization for the above 'save' facility: source the .dirs file
setopt cdable_vars # set the bash option so that no '$' is required when using the above facility

# show dirs at login
echo "Directory shortcuts:" `showdirs`

######## misc ##########

# mkdir, cd into it
mkcd () {
  mkdir -p "$*"
  cd "$*"
}

# Trash files
function trash () {
  local path
  for path in "$@"; do
    # ignore any arguments
    if [[ "$path" = -* ]]; then :
    else
      local dst=${path##*/}
      # append the time if necessary
      while [ -e ~/.Trash/"$dst" ]; do
        dst="$dst "$(date +%H-%M-%S)
      done
      mv "$path" ~/.Trash/"$dst"
    fi
  done
}

function copypath () {
  echo -n $PWD | pbcopy
}
