FROM theflash2k/pwn-chal:latest@sha256:b57ba8ff068a734307f2779502a9b7234e0559e53a6e228cd9bd82f3cdd60878

RUN apt-get update && \
    apt-get install -y libseccomp-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
