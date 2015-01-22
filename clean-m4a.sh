#!/bin/sh

function usage() {
    echo "Usage: clean-m4a FILENAME OUTPUT-DIRECTORY"
    exit
}

export -f usage

if ! [ -f "$1" ]; then
    echo "Error: Specified input file does not exists."
    usage
fi

if ! [ -d "$2" ] || ! [ -w "$2" ]; then
    echo "Error: Can not write to specified output directory."
    usage
fi


ALBUM=$(mp4info "$1" | grep -m 1 Album:  | cut -d ':' -f2 | sed -e 's/^ *//' -e 's/ *$//')
ARTIST=$(mp4info "$1" | grep -m 1 Artist: | cut -d ':' -f2 | sed -e 's/^ *//' -e 's/ *$//')
ALBUM_ARTIST=$(mp4info "$1" | grep -m 1 "Album Artist:" | cut -d ':' -f2 | sed -e 's/^ *//' -e 's/ *$//')
TITLE=$(mp4info "$1" | grep -m 1 Name: | cut -d ':' -f2 | sed -e 's/^ *//' -e 's/ *$//')
TRACK=$(mp4info "$1" | grep -m 1 Track: | cut -d ':' -f2 | cut -d ' ' -f2 | sed -e 's/^ *//' -e 's/ *$//')
TRACKNUM=$(mp4info "$1" | grep -m 1 Track: | cut -d ':' -f2 | cut -d ' ' -f4 | sed -e 's/^ *//' -e 's/ *$//')
YEAR=$(mp4info "$1" | grep -m 1 "Release Date": | cut -d ':' -f2 | cut -d '-' -f1 | sed -e 's/^ *//' -e 's/ *$//')

echo $ALBUM
echo $ARTIST
echo $ALBUM_ARTIST
echo $TITLE
echo $TRACK
echo $TRACKNUM
echo $YEAR

OUT_FILENAME=$(echo "$1" | rev | cut -d '/' -f1 | rev)
OUT_FULL_PATH="$2"/"$OUT_FILENAME"
MP4Box -single 1 "$1" -out "$OUT_FULL_PATH"

mp4tags -A "$ALBUM" -a "$ARTIST" -i "music" -R "$ALBUM_ARTIST" -s "$TITLE" -t "$TRACK" -T "$TRACKNUM" -y "$YEAR" "$OUT_FULL_PATH"