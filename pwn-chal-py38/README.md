## PWN-CHAL - Python3

[Dockerhub](https://hub.docker.com/repository/docker/theflash2k/pwn-chal/)

You can use this image to easily deploy your remote python challenges without having to setup anything. This utilizes the base image: `python:3.8-slim-buster`

A sample Dockerfile is as follows:

```dockerfile
FROM theflash2k/pwn-chal:python

ENV CHAL_NAME=baby-pwn-py
COPY ${CHAL_NAME} ${CHAL_NAME}
COPY flag.txt flag.txt
```

The only difference between this and `pwn-chal:latest` is:

```sh
FIRSTLINE=$(head -n 1 "/app/$CHAL_NAME")
if [ ! "${FIRSTLINE:0:3}" == '#!/' ]; then
    (echo '#!/usr/bin/env python3' | cat - "/app/$CHAL_NAME") > tmp && mv tmp "/app/$CHAL_NAME"
fi
```