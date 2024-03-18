FROM theflash2k/pwn-chal:latest@sha256:b57ba8ff068a734307f2779502a9b7234e0559e53a6e228cd9bd82f3cdd60878

# Just install the 32-bit stuff
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y libc6:i386 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
