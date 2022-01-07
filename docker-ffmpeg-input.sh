#!/bin/bash
# $arg1: stream name 
# $arg2: RTSP Url
# $arg3: YouTube stream key

docker rm -f $1
docker run --name $1  --restart unless-stopped -d --network host \
-v $(pwd):/config \
linuxserver/ffmpeg \
-strict experimental \
-hide_banner \
-loglevel warning \
-flags  +genpts \
-vsync cfr -stimeout 10000000 -rtsp_transport tcp -max_delay 10000000 -reorder_queue_size 30000 -thread_queue_size 1024 -i $2 \
-c:v copy \
-c:a aac \
-af "aresample=async=1" \
-bufsize 4000k \
-f flv \
rtmp://live1a.dal1.vrf.tv:1935/static/$1
-c:v copy \
-c:a aac \
-af "aresample=async=1" \
-bufsize 4000k \
-f flv \
rtmps://a.rtmp.youtube.com/live2/$4