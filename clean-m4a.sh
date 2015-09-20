#!/bin/bash
# clean-m4a removes all metadata from an m4a file by replaying its whole container
# by a new one and only copies non-personal metadata from the old file.
# Input files are overwritten by processed files, so better make a backup of your
# original files in case of undesired behaviour. 
# If you still encounter any file corruptions after interrupting the script with SIGINT,
# please leave me a message. 

function usage() {
    echo "m4a-clean removes all metadata from MP4/m4a audio files."
    echo "Usage: clean-m4a filename1 filename2 ..."
    exit
}

trap ctrl_c SIGINT

function ctrl_c() {
    CANCELED=YES
}

function process_file() {
    
    if ! [[ $(file "$1") =~ .*IS0\ 14496-12:2003.* ]]; then
        echo Skipping "$1"
    else
        ALBUM=$(mp4info "$1" | grep -m 1 Album:  | cut -d ':' -f2 | sed -e 's/^ *//' -e 's/ *$//')
        ARTIST=$(mp4info "$1" | grep -m 1 Artist: | cut -d ':' -f2 | sed -e 's/^ *//' -e 's/ *$//')
        ALBUM_ARTIST=$(mp4info "$1" | grep -m 1 "Album Artist:" | cut -d ':' -f2 | sed -e 's/^ *//' -e 's/ *$//')
        TITLE=$(mp4info "$1" | grep -m 1 Name: | cut -d ':' -f2 | sed -e 's/^ *//' -e 's/ *$//')
        TRACK=$(mp4info "$1" | grep -m 1 Track: | cut -d ':' -f2 | cut -d ' ' -f2 | sed -e 's/^ *//' -e 's/ *$//')
        TRACKNUM=$(mp4info "$1" | grep -m 1 Track: | cut -d ':' -f2 | cut -d ' ' -f4 | sed -e 's/^ *//' -e 's/ *$//')
        YEAR=$(mp4info "$1" | grep -m 1 "Release Date": | cut -d ':' -f2 | cut -d '-' -f1 | sed -e 's/^ *//' -e 's/ *$//')

        OUT_FILENAME=$(echo "$1" | rev | cut -d '/' -f1 | rev)
        OUT_RAND=$(hexdump -n 16 -v -e '/1 "%02X"' /dev/urandom)
        if ! [ -d /tmp/m4aclean ]; then
            mkdir -p /tmp/m4aclean
        fi

        OUT_FULL_PATH=/tmp/m4aclean/"$OUT_RAND"-"$OUT_FILENAME"
        nohup MP4Box -single 1 "$1" -out "$OUT_FULL_PATH" &
        wait $!
        nohup mp4tags -A "$ALBUM" -a "$ARTIST" -i "music" -R "$ALBUM_ARTIST" -s "$TITLE" -t "$TRACK" -T "$TRACKNUM" -y "$YEAR" "$OUT_FULL_PATH" &
        wait $!
        
        if [[ $CANCELED == YES ]]; then
            echo "m4a cleaning canceled by user."
            exit
        else
            nohup mv "$OUT_FULL_PATH" "$1" &
            wait $!
        fi

    fi

}

INPUT=""

export -f usage
export -f process_file

for OPT in "$@"; do
    case $OPT in
        -h|--help)
        usage
        ;;
        -r|--recursive)
        REC_SEARCH=YES
        ;;
        *)
        INPUT=$INPUT"$OPT\n"
        ;;
    esac
done

IFS=$'\n'
for ARG in $(echo -e "$INPUT"); do
    if [[ -f "$ARG" ]]; then
        process_file "$ARG"
    elif [[ -d "$ARG" ]]; then
        if [[ $REC_SEARCH == YES ]]; then
            for FILE in $(find "$ARG" -name "*.m4a"); do process_file "$FILE"; done
        else
            for FILE in $(find "$ARG" -maxdepth 1 -name "*.m4a"); do process_file "$FILE"; done
        fi
    fi
done
