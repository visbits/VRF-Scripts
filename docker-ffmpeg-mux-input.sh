#!/bin/bash
# $arg1: stream name
# $arg2: RTSP Url Video
# $arg3: RTSP Url Audio
# $arg4: YouTube stream key
#https://www.axis.com/vapix-library/subjects/t10175981/section/t10036015/display

streamName=$1
videoUrl=$2
audioUrl=$3
youtubeKey=$4
password=$5
bitrate=2800
maxBitrate=4000

docker rm -f $streamName
docker run --name $streamName  --restart unless-stopped -d --network host \
-v $(pwd):/config \
linuxserver/ffmpeg \
-strict experimental \
-hide_banner \
-fflags nobuffer+discardcorrupt+igndts \
-loglevel warning \
-err_detect explode \
-abort_on empty_output_stream \
-rtsp_transport tcp -max_delay 3000000 -reorder_queue_size 30000 -thread_queue_size 1024 -stimeout 10000000 \
-i $videoUrl"?overlays=all&audio=0&video=1&resolution=1920x1080&compression=30&videocodec=h264&h264profile=main&fps=30&videokeyframeinterval=60&videobitrate=$bitrate&videomaxbitrate=$maxBitrate" \
-rtsp_transport tcp -max_delay 3000000 -reorder_queue_size 30000 -thread_queue_size 1024 -stimeout 10000000 \
-i $audioUrl"?audio=1&video=0" \
-f fifo -fifo_format flv \
-c:v copy \
-c:a aac \
-ar 44100 \
-ab 128k \
-af "aresample=async=1" \
-map 0:v:0 -map 1:a:0 \
-drop_pkts_on_overflow 1 -attempt_recovery 1 -recovery_wait_time 5 -restart_with_keyframe 1 \
rtmp://localhost:1935/static/$streamName?password=$password \
-f fifo -fifo_format flv \
-c:v copy \
-c:a aac \
-ar 44100 \
-ab 128k \
-af "aresample=async=1" \
-map 0:v:0 -map 1:a:0 \
-drop_pkts_on_overflow 1 -attempt_recovery 1 -recovery_wait_time 5 -restart_with_keyframe 1 \
rtmps://a.rtmp.youtube.com/live2/$youtubeKey
