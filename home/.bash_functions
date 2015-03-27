#!/bin/bash
git() {
   # Credit: http://unix.stackexchange.com/a/97958/16485
   local tmp=$(mktemp)
   local repo_name

   if [ "$1" = clone ] ; then
     /usr/bin/git "$@" | tee $tmp
#     repo_name=$(awk -F\' '/Cloning into/ {print $2}' $tmp)
     repo_name=$(perl -nE 'm/Cloning into '\''(\w+)\'\''.{3}$/; say $1 if $1;' $tmp)
     rm $tmp
     printf "changing to directory %s\n" "$repo_name"
     cd "$repo_name"
   else
     /usr/bin/git "$@"
   fi
}
vagrant-all() { # pass cmd to all vagrant boxes
     for vm in $(vagrant status | cut -d' ' -f 1 | grep -Poz '(?s)\s{2}^(.*)\s{2}' | sed '/^$/d'); do
         vagrant $@ $vm
     done
}
editall() { # edit all files by file extension
     find . -type f -iname '*.'"$1" -and -not -iname '__init__*' -exec vim -p {} +
}
noscrob() { # disable lastfm scrobbling while practicing music
     sudo service lastfmsubmitd stop &&\
     muzik &&\
     sudo service lastfmsubmitd start
}
dirwatch() { # run ls repeatedly with colors preserved
     watch --color "ls -lsh --color $1"
}
genpw() { # generate random 30-character password
    strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo
}
ackr() { # for all files matching regex1, perform in-place substition with regex2
    ack-grep $1 -l | xargs perl -pi -E "$2"
}
gethtmlformfields() { # spit out list of HTML form field "name"s
    perl -nE '/name=['\''"](\w+)['\''"]/; say $1 if $1;' "$1" | awk '!x[$0]++'
}
wp() { #short wikipedia entries from DNS query
    dig +short txt "$*".wp.dg.cx
}
formyeyes() { # enable redshift at this geographic location (IP-based);
    redshift -l `latlong` > /dev/null & # feed current location data into redshift;
}
touchpad() {
    # this works on X220, but not on X1 Carbon 3rd-gen
    trackpad_id=`xinput list | grep TouchPad | perl -ne 'm/id=(\d+)/g; print $1'`

    case "$1" in
        "")
           echo "Usage: touchpad [on|off]"
           RETVAL=1
           ;;
        on)
           trackpad_state=0
           ;;
        off)
           trackpad_state=1
           ;;
    esac

    xinput --set-prop $trackpad_id "Synaptics Off" $trackpad_state
}
extr_mp3() { 
    ffmpeg -i "$1" -f mp4 -ar 44100 -ac 2 -ab 192k -vn -y -acodec copy "$1.mp3"
}
top10() {
    history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}
sharefile() { #spin up a temporary webserver to serve target file for one HTTP GET
    FILE=$1
    PORT=$2 || 80
    echo "Currently sharing file '$1'. This file will only be available for one transfer."
    ADDRESS_IP="http://$(hostname -I | sed 's/ //g')/$FILE" #grab local IP and build URL for it (also remove trailing space)
    echo "File will be available on the local network at: 
    $ADDRESS_IP" #provide URL where target file is accessible
    sudo nc -v -l $PORT < "$FILE" #call netcat to host file on port 80
}
rnum() {
    echo $(( $RANDOM % $@ ))
}
iploc() { #Find geographic location of an IP address
    lynx -dump http://www.ip-adress.com/ip_tracer/?QRY=$1 | \
        grep address | \
        egrep 'city|state|country' | \
        awk '{print $3,$4,$5,$6,$7,$8}' | \
        sed 's\ip address flag \\' | \
        sed 's\My\\'
}
ugrep() { #look up Unicode characters by name
    egrep -i "^[0-9a-f]{4,} .*$*" $(locate CharName.pm) | while read h d; do /usr/bin/printf "\U$(printf "%08x" 0x$h)\tU+%s\t%s\n" $h "$d"; done
}

canhaz() {
    sudo aptitude -y install $@
}
getem() {
    sudo aptitude update
    sudo aptitude -y safe-upgrade
}
slg() {
    tail -f -n 25 /var/log/syslog
}
newestfiles() {
    #Ignores all git and subversion files/directories, because who wants to sort those?
    #Date statement could be cleaner, though; gets ugly on long filenames
    find "$@" -not -iwholename '*.svn*' -not -iwholename '*.git*' -type f -print0 | xargs -0 ls -l --time-style='+%Y-%m-%d_%H:%M:%S' | sort -k 6 | tail -n 10
}
muzik() {
    if [ -d "$heimchen" ]; then
        mocp
    else 
        gjallar
        mocp
    fi
}
f() { #Abbreviated find command. Assumes cwd as target, and ignores version control files.
    find . -not -iwholename '*.svn*' -not -iwholename '*.git*' -iname "*$@*"
}
strlength() { #print length of given string
    echo "$@" | awk '{ print length }'
}
makeiso() { # create ISO from CD/DVD
    ISONAME=$@
    dd if=/dev/sr0 of="$ISONAME.iso"
}
burniso() { # burn ISO to DVD
    ISONAME=$@
    growisofs -dvd-compat -Z /dev/sr0="$ISONAME"
}
atb() {
    l=$(tar tf $1);
    if [ $(echo "$l" | wc -l) -eq $(echo "$l" | grep $(echo "$l" | head -n1) | wc -l) ];
        then tar xf $1;
    else mkdir ${1%.t(ar.gz||ar.bz2||gz||bz||ar)} &&
        tar xf $1 -C ${1%.t(ar.gz||ar.bz2||gz||bz||ar)};
    fi;
}
