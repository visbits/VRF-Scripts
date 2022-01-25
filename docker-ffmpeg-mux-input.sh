#!/bin/bash
# $arg1: stream name
# $arg2: RTSP Url Video
# $arg3: RTSP Url Audio
# $arg4: YouTube stream key
#https://www.axis.com/vapix-library/subjects/t10175981/section/t10036015/display

docker rm -f $1
docker run --name $1  --restart unless-stopped -d --network host \
-v $(pwd):/config \
linuxserver/ffmpeg \
-strict experimental \
-hide_banner \
-loglevel warning \
-err_detect explode \
-abort_on empty_output_stream \
-rtsp_transport tcp -max_delay 3000000 -reorder_queue_size 30000 -thread_queue_size 1024 -stimeout 10000000 \
-i $2"?resolution=1920x1080&audio=0&video=1&compression=30&videocodec=h264&fps=30&videokeyframeinterval=60&videobitrate=2800&videomaxbitrate=4000" \
-rtsp_transport tcp -max_delay 3000000 -reorder_queue_size 30000 -thread_queue_size 1024 -stimeout 10000000 \
-i $3"?audio=1&video=0&audioencoding=aac&samplerate=44100&bitrate=128" \
-f fifo -fifo_format flv \
-c:v copy \
-c:a aac \
-ar 44100 \
-ab 128k \
-af "aresample=async=1" \
-map 0:v:0 -map 1:a:0 \
-drop_pkts_on_overflow 1 -attempt_recovery 1 -recovery_wait_time 5 -restart_with_keyframe 1 \
rtmp://localhost:1935/static/$1 \
-f fifo -fifo_format flv \
-c:v copy \
-c:a aac \
-ar 44100 \
-ab 128k \
-af "aresample=async=1" \
-map 0:v:0 -map 1:a:0 \
-drop_pkts_on_overflow 1 -attempt_recovery 1 -recovery_wait_time 5 -restart_with_keyframe 1 \
rtmps://a.rtmp.youtube.com/live2/$3
