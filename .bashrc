#bashrc file
#location: $HOME/.bashrc or ~/.bashrc
#last modified: 1/18/13

#Make commands interactive
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
#Add color and /s to directory names
alias ls="ls -aFG --color"
#Silence displaying every action
alias make="make -s"
#Edit svn ignore settings
alias svnignore="svn propedit svn:ignore ."
#Make vim the default editor
export EDITOR=vim
export LC_ALL="en_US.utf8"

export JAVA_HOME=/usr/lib/jvm/java-8-oracle/
export PATH=$PATH:$JAVA_HOME/bin 
export PATH=$PATH:/home/site/scripts

export FIGNORE=.svn

if [ "$TRTOP" = "" ] ; then
    export TRTOP="/home/site/trsrc-MAINLINE"
fi

#TMUX config
if [ "$TMUX" != "" ] ; then
    export PROMPT_COMMAND="tmux rename-window \$PWD; $PROMPT_COMMAND"
    export PROMPT_COMMAND="tmux set-environment TRTOP \$TRTOP; $PROMPT_COMMAND"
fi

#Rio
alias rio='connect-rio rio'
alias riodev='connect-rio riodev'
function connect-rio {
    echo "Username:"
    read username
    psql -h $1.cta9rlboj2sy.us-east-1.redshift.amazonaws.com -p 5439 -U $username $1
}

function ack {
   for arg in $*; do
       if [[ "$arg" != "-"* ]]; then
           echo $arg | sed 's/"/\\"/g' > ~/.vim/acksearch
           break
       fi  
   done
   /usr/bin/env ack-grep "$@"
}

function v {
    $@ | vim -R -
}

function c {
    curpwd=`pwd`
    trimpwd=${curpwd#$TRTOP}
    echo $TRTOP/../trsrc-$@$trimpwd
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

#Warehouse stuff:
if [ -n "$PS1" -a -f /home/site/warehouse-ng/warehouse.bash.env ]; then
    source /home/site/warehouse-ng/warehouse.bash.env
    alias hive="hive -hiveconf mapred.job.queue.name=rna"
fi

#Set up command line
function EXT_COLOR () { echo -ne "\[\033[38;5;$1m\]"; }
HOST_COLOR="`EXT_COLOR 28`"     #Green
#HOST_COLOR="`EXT_COLOR 160`"    #Red
DIR_COLOR="`EXT_COLOR 18`"      #Blue
BLCK="`EXT_COLOR 0`"            #Black 
PS1_LN1="[${HOST_COLOR}\u@\h${BLCK}:${DIR_COLOR}\w${BLCK}]"
PS1_LN2="\D{%T} \W\$ "
PS1="\n$PS1_LN1\n$PS1_LN2"

#Tripadvisor specific stuff
export SVN_EDITOR=/usr/bin/vim

function tl()
{
    cd $TRTOP
    ant compile-tr merge-classes
    cd -
}

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
    export JAVA="$TRTOP/tr/com/TripResearch/servlet/tablet"
    export VELOCITY="$TRTOP/site/velocity_redesign/tablet/redesign"
    export DUST="$TRTOP/site/dust/src/tablet"
    export BASE="$TRTOP/site/css2/mobile/base.less"
}
newtrtopenv
export PROMPT_COMMAND="findtrtop; $PROMPT_COMMAND"

cd $TRTOP 
