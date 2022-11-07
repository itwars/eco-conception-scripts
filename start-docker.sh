#!/usr/bin/env sh

docker run -it --rm --hostname=alpine -p 80:80 -v ${PWD}:/root alpine:latest /bin/sh
