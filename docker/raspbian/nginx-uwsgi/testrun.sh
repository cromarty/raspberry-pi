#!/bin/bash

IMAGE=mike

docker run -d \
    --name uwsgi \
    -p 8080:80 \
    ${IMAGE}


