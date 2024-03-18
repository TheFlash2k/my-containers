#!/bin/bash

docker build -t theflash2k/pwn-dev:2204 .
docker tag theflash2k/pwn-dev:2204 theflash2k/pwn-dev:latest
docker build -t theflash2k/pwn-dev:18.04 -f Dockerfile.1804 .
docker build -t theflash2k/pwn-dev:20.04 -f Dockerfile.2004 .
