FROM ubuntu:20.04

RUN apt update \
    && \
    DEBIAN_FRONTEND="noninteractive" TZ="America/New_York" \
    apt install -y \
        qemu-user \
        binutils-arm-linux-gnueabihf \
        libc6-armhf-cross \
    && \
    apt-get clean

## All of this is from pwn-chal base image:
RUN  mkdir -p /app/
WORKDIR /app
RUN adduser --disabled-password ctf-player

# Setting up challenge stuff
COPY utilities/flag.txt /app/flag.txt
COPY utilities/chal /app/chal
COPY utilities/ynetd /opt/ynetd
COPY utilities/socat /opt/socat
RUN chmod +x /opt/*

# Setting up log stuff
RUN touch /var/log/chal.log
RUN chown -R root:ctf-player /var/log/chal.log
RUN chmod 740 /var/log/chal.log

# Other measures
RUN chmod o-rwx / 2>/dev/null

COPY docker-entrypoint.sh /docker-entrypoint.sh
CMD ["/docker-entrypoint.sh"]
