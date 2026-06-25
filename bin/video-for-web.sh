#!/usr/bin/env bash
for i in *.mp4; do ffmpeg -i "$i" -c:a aac -b:a 128k -c:v libx264 -crf 28 -vf "scale='min(-2,iw)':'min(1080,ih)'" "${i%.mov}.mp4"; done

# For every movie in this folder
# for i in *.mov;

# Run ffmpeg passing in the file name
# do ffmpeg -i "$i"

# Advanced Audio Codec for audio
# -c:a aac

# bit rate for the audio should be 128k
# -b:a 128k -

# use h264 compression for video
# -c:v libx264

# set the bitrate for the compression 18 -> 28 for h264
# -crf 28

# scale the video to a minimum height of 1080p
# -vf "scale='min(-2,iw)':'min(1080,ih)'"

# name it the same changing the extension to .mp4
# "${i%.mov}.mp4"; done
