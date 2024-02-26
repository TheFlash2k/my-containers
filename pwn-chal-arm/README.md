# PWN-CHAL:armv8

This is just a tag of the `pwn-chal` container. Everything else is the same, the only thing that's different is that it has `qemu` installed with armv7 configurations.

You can find more about the usage for this on [Dockerhub](https://hub.docker.com/repository/docker/theflash2k/pwn-chal/)

## NOTE:

In order to run this container, run the following command on the host:

[Reference](https://devopstales.github.io/linux/running_and_building_multi_arch_containers/)

```bash
# Install the qemu packages
sudo apt-get install qemu binfmt-support qemu-user-static

# This step will execute the registering scripts
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

A sample Dockerfile for a challenge will be as follows:

```dockerfile
FROM theflash2k/pwn-chal:armv8

ENV CHAL_NAME=baby-arm
COPY ${CHAL_NAME} ${CHAL_NAME}
COPY flag.txt flag.txt
```
