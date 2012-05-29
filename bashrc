# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

shopt -s histappend # append to the history file, don't overwrite it
shopt -s cmdhist #Multi-line commands are still entered into history

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

#this corrects typos when spelling out paths.
shopt -s cdspell

shopt -s autocd #change directories with just a pathname

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias l='ls -lsh'
alias ll='ls -lsh'
alias la='ls -lash'
alias rsync='rsync -avPh'
alias bi='beet import'
alias gits='git status'
alias gc='git commit'
alias gd='git diff'
alias ga='git add'
alias ack='ack-grep'
alias gh='github_browse.pl'
alias pushall='git_push_all.pl'
alias externalip='curl ifconfig.me'
alias internalip='hostname -I'
alias whereami='externalip | iploc'
alias whoshere='sudo watch arp-scan --interface=wlan0 --localnet' #arp-scan not very portable; should use nmap instead, e.g.:
#nmap -sP 192.168.1.0/24; arp -n  | grep "192.168.1.[0-9]* *ether"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export PATH=$PATH:/home/conor/Documents/Coding/Cute\ names\ for\ scripts
export heimchen="/home/conor/Valhalla/Media/Heimchen"
export PATH=$PATH:/home/conor/.bin
#export PATH=$PATH:/home/conor/Documents/Coding
#export PATH="${PATH}$(find /home/conor/githubrepos -name '.*' -prune -o -type d -printf ':%p')"
#export PATH=$PATH:$(find /home/conor/githubrepos -type d | sed '/\/./d' | tr '\n' ':' | sed 's/:$//') 

#PS1="[ \! ] \u@\h{ \w }\a $(parse_git_branch): " #[ history ] user@hostname{ cwd } sigil:
PS1="( \! ) \u@\h{ \w }\a: " #( history ) user@hostname{ cwd } sigil:

## BEGIN @climagic tips
function matrix(){
    for t in "Wake up" "The Matrix has you" "Follow the white rabbit" "Knock, knock";do pv -qL10 <<<$'\e[2J'$'\e[32m'$t$'\e[37m';sleep 5;done;reset
}
extr_mp3(){ 
    ffmpeg -i "$1" -f mp4 -ar 44100 -ac 2 -ab 192k -vn -y -acodec copy "$1.mp3"
}
starwars(){
    telnet towel.blinkenlights.nl
}
nyancat(){
    telnet miku.acm.uiuc.edu
}
top10(){
    history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}
sharefile(){ #spin up a temporary webserver to serve target file for one HTTP GET
    echo "Currently sharing file '$@'. This file will only be available for one transfer."
    SYMLINK_NAME=$(echo "$@" | sed 's/ //g') #remove whitespace (full escape char support would be better)
    ln -s "$@" "$SYMLINK_NAME" #create symlink with whitespace removed to point to target file
    ADDRESS_IP="http://$(hostname -I | sed 's/ //g')/$SYMLINK_NAME" #grab local IP and build URL for it (also remove trailing space)
    echo "File will be available on the local network at: 
    $ADDRESS_IP" #provide URL where target file is accessible
    sudo nc -v -l 80 < "$@" #call netcat to host file on port 80
    rm $SYMLINK_NAME #remove the symlink, as it's no longer necessary
}
rnum(){
    echo $(( $RANDOM % $@ ))
}
md () { 
    mkdir -p "$@" && cd "$@"; 
}
function iploc() { #Find geographic location of an IP address
    lynx -dump http://www.ip-adress.com/ip_tracer/?QRY=$1|grep address|egrep 'city|state|country'|awk '{print $3,$4,$5,$6,$7,$8}'|sed 's\ip address flag \\'|sed 's\My\\'
}
function weather() { #grab weather via Yahoo! weather APIs; lynx would be more portable than elinks
    zipcode="$@"
    elinks -dump "http://weather.yahooapis.com/forecastrss?p=${zipcode}" | grep -A 4 "Current "
}
### END @climagic tips


function canhaz(){
    sudo aptitude -y install $@
}
function getem(){
    sudo aptitude update
    sudo aptitude -y safe-upgrade
}
function refresh(){
    cd ~/gits/dotfiles
    git pull
    . ~/.bashrc
    cd -
}
function journal(){
    lowriter ~/Documents/Journal.odt
}
function slg(){
    tail -f -n 25 /var/log/syslog
}
function newestfiles(){
    #Ignores all git and subversion files/directories, because who wants to sort those?
    #Date statement could be cleaner, though; gets ugly on long filenames
    find "$@" -not -iwholename '*.svn*' -not -iwholename '*.git*' -type f -print0 | xargs -0 ls -l --time-style='+%Y-%m-%d_%H:%M:%S' | sort -k 6 
}
function explodeavi(){
    ffmpeg -i "$@" -f image2 image-%03d.jpg
}
function resetconnection() {
    sudo nmcli nm wifi off
    sleep 5
    sudo nmcli nm wifi on
}
function giveroot(){
    sudo usermod -aG sudo $@
}
function toritup() {
    ssh -f -2 -N -L 127.0.0.1:9049:127.0.0.1:9050 w 
}
function rsyncssh() {
    rsync -e "ssh" -avPh $@
}
function cds() {
    cd $@ && ls -lsh
}
function muzik() {
    if [ -e /home/conor/Valhalla/Media/Heimchen ] 
        then
            mocp
    else 
       gjallar
       mocp
    fi
}
function cdls() { 
    cd $1 
    ll
}
function splittracks() {
    echo "Attempting to split audio tracks now... "
    rename -v 's/ /_/g' *
    cuebreakpoints $1 | shnsplit -o flac $2
    cuetag $1 split-track*
    echo "All done!"
}
function f() { #Abbreviated find command. Assumes cwd as target, and ignores version control files.
    find . -not -iwholename '*.svn*' -not -iwholename '*.git*' -iname "*$@*"
}
function tssh() { #Connect to many machines via SSH by invoking tmux;
    declare -a HOSTS=$@ #Necessary to rename array due to quoting quirks
    tmux new "ssh-everywhere.sh $HOSTS" #Open new tmux session by calling script;
}

#set -o vi #Set vi input mode (instead of default emacs style)
function g() { 
    lynx -dump "http://google.com/search?q=$*" | more
}
function afterdownload() { #complete action after a download or transfer completes
    while [ -e $1 ] #$1 should be (hidden) partial file for download
        do sleep 1 #wait, check again
    done
    "$2" #perform designated action, supplied as second argument
}
