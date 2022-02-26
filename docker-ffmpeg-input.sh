#!/bin/bash
# $arg1: stream name
# $arg2: RTSP Url
# $arg3: YouTube stream key

streamName=$1
audioVideoUrl=$2
youtubeKey=$3
password=$4
bitrate=3400
maxBitrate=4000
mode=tcp

docker rm -f $streamName
docker run --name $streamName  --restart unless-stopped -d --network host \
-v $(pwd):/config \
linuxserver/ffmpeg \
-strict experimental \
-hide_banner \
-fflags discardcorrupt+igndts \
-loglevel warning \
-err_detect explode \
-abort_on empty_output_stream \
-rtsp_transport $mode -max_delay 3000000 -reorder_queue_size 30000 -thread_queue_size 4096 -stimeout 4000000 \
-i $audioVideoUrl"?overlays=all&resolution=1920x1080&audio=1&video=1&compression=30&videocodec=h264&h264profile=main&fps=30&videokeyframeinterval=60&audioencoding=aac&videobitrate=$bitrate&videomaxbitrate=$maxBitrate" \
-f flv \
-c:v copy \
-c:a aac \
-ar 44100 \
-ab 128k \
-af "aresample=async=1" \
-map 0:v -map 0:a \
rtmp://localhost:1935/static/$streamName?password=$password \
-f flv \
-c:v copy \
-c:a aac \
-ar 44100 \
-ab 128k \
-af "aresample=async=1" \
-map 0:v -map 0:a \
rtmps://a.rtmp.youtube.com/live2/$youtubeKey
