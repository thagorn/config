#bashrc file
#location: $HOME/.bashrc or ~/.bashrc
#last modified: 1/18/13

### Aliases ###
#Make commands interactive
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
#Add color and /s to directory names
alias ls="ls -aFG --color"
#Silence displaying every action
alias make="make -s"
#Make vim the default editor
alias vi=vim
export EDITOR=vim
export LC_ALL="en_US.utf8"
export LANG="en_US.UTF-8"

### TMUX config ###
if [ "$TMUX" != "" ] ; then
    export PROMPT_COMMAND="tmux rename-window \$PWD; $PROMPT_COMMAND"
    export PROMPT_COMMAND="tmux set-environment TRTOP \$TRTOP; $PROMPT_COMMAND"
fi

### FUNCTIONS ###

function ag {
   for arg in $*; do
       if [[ "$arg" != "-"* ]]; then
           echo $arg | sed 's/"/\\"/g' > ~/.vim/agsearch
           break
       fi  
   done
   /usr/bin/env ag "$@"
}

function v {
    $@ | vim -R -
}

function vf {
    rm -rf /tmp/vlinks
    mkdir /tmp/vlinks
    find `pwd -P` -iname "$1*" -not -name "*.class" -not -path "*.svn*" > /tmp/vlink_files
    VCOUNT=`wc -l /tmp/vlink_files | cut -d" " -f1`
    if [ $VCOUNT -eq 0 ] ; then
        echo "No results for $1"
    elif [ $VCOUNT -eq 1 ] ; then
        vim `cat /tmp/vlink_files`
    else
        xargs -a /tmp/vlink_files -I% bash -c 'vlink %'
        vim /tmp/vlinks
    fi
}

function vlink {
    FNAME=`echo "$1" | sed 's|/|.|g'`
    ln -s $1 /tmp/vlinks/$FNAME
}
export -f vlink

### Set up command line ###
function EXT_COLOR () { echo -ne "\[\033[38;5;$1m\]"; }
HOST_COLOR="`EXT_COLOR 28`"     #Green
#HOST_COLOR="`EXT_COLOR 160`"    #Red
DIR_COLOR="`EXT_COLOR 18`"      #Blue
BLCK="`EXT_COLOR 0`"            #Black 
PS1_LN1="\[${HOST_COLOR}\u@\h${BLCK}:${DIR_COLOR}\w${BLCK}\]"
PS1_LN2="\D{%T} \W\$ "
PS1="\n$PS1_LN1\n$PS1_LN2"

if [ -f ~/.bash_work_profile ]; then
    source ~/.bash_work_profile
fi
