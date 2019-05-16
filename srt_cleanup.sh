#!/bin/bash
# Script to identify and delete orphan srt files after video files have been deleted
# uncomment line bellow to show more verbosed output
#DEBUG=true
# comment line bellow to prevent SRT files from being deleted
DELETE=true
TARGET="$*"
if [[ -z "$TARGET" ]] || [[ ! -e "$TARGET" ]]; then
        echo "No input directory given!"
        echo "Usage: $0 directory"
        exit
fi
TARGET=`realpath -s "$TARGET"`
find "$TARGET" -iname '*.srt' | while read filename; do
        extension=`basename "$filename" | sed -E 's/^(\/.*\/)*(.*)(\.hr|\.sr|\.en|\.sr-Latn)\..*$/\3/'`
        case $extension in
                '.hr')
                        if [ $DEBUG ];then
                                echo $filename " is croatian subtitle"
                        fi
                        lang=1
                        ;;
                '.sr'|'.sr-Latn')
                        if [ $DEBUG ];then
                                echo $filename " is serbian subtitle"
                        fi
                        lang=2
                        ;;
                '.en')
                        if [ $DEBUG ];then
                                echo $filename " is english subtitle"
                        fi
                        lang=3
                        ;;
                *)
                        if [ $DEBUG ];then
                                echo $filename " is unknown subitle"
                        fi
                        lang=0
                        ;;
        esac
        if [ $lang -ge 1 ]; then
                check_file=`basename "$filename" | sed -E 's/^(\/.*\/)*(.*)(\.hr|\.sr|\.en|\.sr-Latn)(\.srt)$/\2/'`
        else
                check_file=`basename "$filename" | sed -E 's/^(\/.*\/)*(.*)\..*$/\2/'`
                #echo $check_file
        fi
        srt_file=`basename "$filename"`
        dir_name=`dirname "$filename"`
        match="$dir_name/$check_file"
        #echo $match
        if [ -f "$match.mkv" ];then
                if [ $DEBUG ];then
                        echo "Subtitle "$srt_file "is matching MKV"$match.mkv
                fi
        elif [ -f "$match.avi" ];then
                if [ $DEBUG ];then
                        echo "Subtitle "$srt_file "is matching AVI"$match.avi
                fi
        elif [ -f "$match.mp4" ];then
                if [ $DEBUG ];then
                        echo "Subtitle "$srt_file "is matching MP4"$match.avi
                fi
        elif [ -f "$match.m4v" ];then
                if [ $DEBUG ];then
                        echo "Subtitle "$srt_file "is matching M4V"$match.avi
                fi
        else
                echo "Deleting orphan subtitle file "$filename
                if [ $DELETE ]; then
                        rm -f "$filename"
                fi

        fi
done
