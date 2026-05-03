#!/bin/bash

if ! podman image exists localhost/busted-luajit:v2.3.0; then
    podman build -t busted-luajit:v2.3.0 .
fi
 
podman run -i -v "$(pwd)/project:/data" localhost/busted-luajit:v2.3.0
podman run -i -v "$(pwd)/project:/data" ghcr.io/lunarmodules/busted:v2.3.0
