#!/bin/bash

IMAGE=cromarty/raspbian-stretch-nginx-uwsgi

docker run -d \
    --name uwsgi \
    -p 8080:80 \
    ${IMAGE}


