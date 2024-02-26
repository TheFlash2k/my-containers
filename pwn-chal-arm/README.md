# PWN-CHAL:arm

This is just a tag of the `pwn-chal` container. Everything else is the same, the only thing that's different is that it has `qemu-arm` installed along with the required libraries.

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
FROM theflash2k/pwn-chal:arm

ENV CHAL_NAME=baby-arm
COPY ${CHAL_NAME} ${CHAL_NAME}
COPY flag.txt flag.txt
```

## Environment Variables

There is one environment variable that is specific to `arm` based images.

### QEMU_GDB_PORT

This port will be passed to the underlying `qemu-arm` command and will enable remote GDB debugging on the specified port.

| **NOTE**: When debugging is enabled, the container will run, and run the GDB port on the specified port, and since the program will run in a `while [[ 1 ]]` loop, it will continue to do so. However, the `stdin`, `stdout` and `stderr` aren't redirected to GDB, and therefore, running the container with `-d` option will not work the way you'd expect it to.

If you know how to fix it, please contact me, or a simple Pull Request with the fix ;).

A sample Dockerfile with debugging enabled:

```dockerfile
FROM theflash2k/pwn-chal:arm

ENV CHAL_NAME=baby-arm
ENV QEMU_GDB_PORT=7000

COPY ${CHAL_NAME} ${CHAL_NAME}
```

