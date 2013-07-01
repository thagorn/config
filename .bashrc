#bashrc file
#location: $HOME/.bashrc or ~/.bashrc
#last modified: 1/18/13

#Make commands interactive
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
#Add color and /s to directory names
alias ls="ls -aFG"
#Silence displaying every action
alias make="make -s"

export JAVA_HOME=/usr/jdk1.7.0_03 
export PATH=$PATH:$JAVA_HOME/bin 

export FIGNORE=.svn

if [ "$TRTOP" = "" ] ; then
    export TRTOP="/home/site/trsrc-MAINLINE"
fi

#TMUX config
if [ "$TMUX" != "" ] ; then
    export PROMPT_COMMAND="tmux rename-window \$PWD; $PROMPT_COMMAND"
    export PROMPT_COMMAND="tmux set-environment TRTOP \$TRTOP; $PROMPT_COMMAND"
fi

function ack {
   for arg in $*; do
       if [[ "$arg" != "-"* ]]; then
           echo $arg > ~/.vim/acksearch
           break
       fi  
   done
   /usr/bin/env ack-grep "$@"
}

#Set up command line
HOST_COLOR=32 #Green (31 is red)
PS1_BASE='[\[\033[01;${HOST_COLOR}m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]]'
#PS1_TMUX='$(tmux set-environment TRTOP $TRTOP)'
PS1="$PS1_TMUX\n$PS1_BASE\n\W\$ "

#Tripadvisor specific stuff
export SVN_EDITOR=/usr/bin/vim

function findtrtop {
    candidate=`pwd`
    while true; do
        if [[ -e "$candidate/GNUmaster" &&  -e "$candidate/tr" && -e "$candidate/Crawlers" ]]; then
            trtop $candidate
            break;
        else
            nextcandidate=${candidate%/*}
            if [[ "v$nextcandidate" == "v$candidate" || "v$nextcandidate" == "v" ]]; then
                break;
            fi  
            candidate=$nextcandidate
        fi;
    done
}

function trtop {
    if (( $# == 1 )); then
        oldscripts=$TRTOP/scripts
        export TRTOP=$1
        export PATH=${PATH//:$oldscripts}:$TRTOP/scripts
        newtrtopenv
    else
        echo $TRTOP
    fi
}

function newtrtopenv {
    export JS="$TRTOP/site/js3/src/tablet/redesign"
    export CSS="$TRTOP/site/css2/tablet/redesign"
    export VELOCITY="$TRTOP/site/velocity_redesign/tablet/redesign"
}
newtrtopenv
export PROMPT_COMMAND="findtrtop; $PROMPT_COMMAND"

cd $TRTOP 
