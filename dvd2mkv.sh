#!/bin/sh

# determine source
destdir="/Volumes/LHD-ENU3W/Videos/$1"
if [ -e "$destdir/$1.iso" ]; then
    src="$destdir/$1.iso"
else
    src=$(drutil status |grep -m1 -o '/dev/disk[0-9]*')
fi

if [ -z $src ]; then
    echo "no source found!"
    exit
fi

echo "Using $src as source"

# build command
eject=0
notice=0
cmd=""

if [ -z "$1" ]; then
    cmd=" --scan"
    notice=1
else
    case "$1" in 
    eject)
        eject=1
        ;;
    *)
        dest="$destdir/$1.mkv"
        flags=""

        if [ ! -z "$2" ]; then
            flags="--subtitle \"$2\" --subtitle-burned"
        fi

        if [ ! -z "$3" ]; then
            flags="$flags --audio \"$3\""
        fi

        cmd="-o \"$dest\"  --main-feature  --preset \"Fast 1080p30\" $flags"
        mkdir "$destdir"
        eject=1
        ;;
    esac
fi

# execute ops
if [ ! -z "$cmd" ]; then
    echo "HandbrakeCLI --input \"$src\" $cmd"
    sudo bash -c "exec HandbrakeCLI --input \"$src\" $cmd"
fi

if [ "$eject" == "1" ]; then
    drutil eject
fi

if [ "$notice" == "1" ]; then
    echo "dvd2mkv [title name (escaped)] [subtitle id] [audio id]"
fi
