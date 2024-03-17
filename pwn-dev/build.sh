#!/bin/bash

# docker build -t theflash2k/pwn-dev:22.04 .
# docker build -t theflash2k/pwnd-dev:18.04 -f Dockerfile.1804 .
docker build -t theflash2k/pwnd-dev:20.04 -f Dockerfile.2004 .
