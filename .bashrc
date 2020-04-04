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
alias tm="psql -h tripmonster -U tripmonster"
alias jst="tweak feature off js_compress && tweak feature off js_concat"
alias jstt="tweak feature on js_compress && tweak feature on js_concat"
alias remountprodfbrs='sudo umount /usr/local/tripadvisor/prod_fbrs ; sudo mount -t nfs -o ro fbrs-storage:/backup/fbrs/LATEST_PRODUCTION /usr/local/tripadvisor/prod_fbrs'
#Make vim the default editor
alias vi=vim
export EDITOR=vim
export LC_ALL="en_US.utf8"
export LANG="en_US.UTF-8"

export JAVA_HOME=/usr/jdk11
export PATH=$PATH:$JAVA_HOME/bin 
export PATH=$PATH:/home/awhitworth/scripts

export FIGNORE=.svn

if [ "$TRTOP" = "" ] ; then
    export TRTOP="/home/site/trsrc-MAINLINE"
fi
if [ "$SSL_PLATFORM" = "" ]; then
 export SSL_PLATFORM="/home/site/ssl-platform"
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

function comp {
    if [[ "$1" == "check" ]]; then
        /usr/bin/env comp "$@" && printf '\033[0;32mSuccess!\033[0m\n'
    else
        /usr/bin/env comp "$@"
    fi
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
if [ -n "$PS1" -a -f /home/site/warehouse/warehouse.bash.env ]; then
    source /home/site/warehouse/warehouse.bash.env
    alias hive="hive -hiveconf mapred.job.queue.name=eat.adhoc"
fi

#Set up command line
function EXT_COLOR () { echo -ne "\[\033[38;5;$1m\]"; }
HOST_COLOR="`EXT_COLOR 28`"     #Green
#HOST_COLOR="`EXT_COLOR 160`"    #Red
DIR_COLOR="`EXT_COLOR 18`"      #Blue
BLCK="`EXT_COLOR 0`"            #Black 
PS1_LN1="\[${HOST_COLOR}\u@\h${BLCK}:${DIR_COLOR}\w${BLCK}\]"
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
