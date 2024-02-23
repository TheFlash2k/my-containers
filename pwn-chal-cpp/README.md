# PWN-CHAL:CPP

This is just a tag of the `pwn-chal` container. Everything else is the same, the only thing that's different is that it has `g++` installed, which install the `libstd++` and `libc++` which is required for running the binaries written in C++.

You can find more about the usage for this on [Dockerhub](https://hub.docker.com/repository/docker/theflash2k/pwn-chal/)

A sample Dockerfile for a challenge will be as follows:

```dockerfile
FROM theflash2k/pwn-chal:cpp

ENV CHAL_NAME=baby-pwn-plusplus
COPY ${CHAL_NAME} ${CHAL_NAME}
COPY flag.txt flag.txt
```