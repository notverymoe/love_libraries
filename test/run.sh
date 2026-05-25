#!/bin/bash

if ! podman image exists localhost/busted-luajit:v2.3.0; then
    podman build -t localhost/busted-luajit:v2.3.0 -f $(pwd)/test/LuaJit.ContainerFile
fi

if ! podman image exists localhost/busted-lua51:v2.3.0; then
    podman build -t localhost/busted-lua51:v2.3.0 -f $(pwd)/test/Lua51.ContainerFile
fi
 
podman run -i -v "$(pwd)/project:/data" localhost/busted-luajit:v2.3.0
podman run -i -v "$(pwd)/project:/data" localhost/busted-lua51:v2.3.0
