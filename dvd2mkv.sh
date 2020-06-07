#!/bin/sh

title=""
audio_track=""
subtitle_track=""
eject=""
noeject=""
notice=""
info=""
translate_japanese=""
convert=""

while getopts nicet:a:s:j opt
do
    case $opt in 
    i)
        info="1"
        echo "info selected."
        ;;
    c)
        convert="1"
        echo "convert selected."
        ;; 
    e)
        eject="1"
        echo "eject selected."
        ;;
    n)
        noeject="1"
        echo "noeject selected."
        ;;
    a)
        audio_track="$OPTARG"
        echo "audio_track $OPTARG selected."
        ;;
    s)
        subtitle_track="$OPTARG"
        echo "subtitle_track $OPTARG selected."
        ;;
    t)
        title="$OPTARG"
        echo "title=$OPTARG selected."
        ;;
    j)
        translate_japanese="1"
        echo "translate_japanese selected."
        ;;
    esac
done

shift $((OPTIND - 1))

# translate title if requested
if [ ! -z "$translate_japanese" -a ! -z "$title" ]; then
    english_title=$(./get_title $title)

    if [ -z "$english_title" ]; then
        echo "Title is ambiguous. Please choose from below:"
        ./get_title -a -j $title
        exit
    fi

    title=$english_title
fi

echo Title is $title

# determine source and destination
src=""
destdir=""
if [ ! -z "$title" ]; then
    # determine source
    destdir="/Volumes/LHD-ENU3W/Videos/$title"
    if [ -e "$destdir/$title.iso" ]; then
        src="$destdir/$title.iso"
    fi
fi

if [ -z "$src" ]; then
    src=$(drutil status |grep -m1 -o '/dev/disk[0-9]*')

    if [ -z $src ]; then
        echo "no source found!"
    else
        echo "Using $src as source"
    fi
fi

# build command
cmd=""

if [ ! -z "$src" -a ! -z "$title" -a "$convert" == "1" ]; then
    dest="$destdir/$title.mkv"
    flags=""

    if [ ! -z "$subtitle_track" ]; then
        flags="--subtitle \"$subtitle_track\" --subtitle-burned"
    fi

    if [ ! -z "$audio_track" ]; then
        flags="$flags --audio \"$audio_track\""
    fi

    cmd="-o \"$dest\"  --main-feature  --preset \"Fast 1080p30\" $flags"
    mkdir -p "$destdir" 
    if [ -z "$noeject" ]; then
        eject="1"
    fi
fi

if [ -z "$cmd" -a "$info" == "1" ]; then
    cmd=" --scan"
    notice="1"
fi

if [ -z "$cmd" -a "$eject" != "1" ]; then
    notice="1"
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
    echo "dvd2mkv [-t <title name (escaped)>] [-s <subtitle id>] [-a <audio id>] [-e] [-j]"
fi
