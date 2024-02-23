## PWN-CHAL - Easy remote PWN challenges deployment

[Dockerhub](https://hub.docker.com/repository/docker/theflash2k/pwn-chal/)

You can use this image to easily deploy your challenges without having to setup anything.
Under the hood, pwn-chal utilizes [`ynetd`](https://github.com/johnsonjh/ynetd) to serve the challenge to host. `socat` can be utilized as well by setting `BASE` environment variable.

A sample Dockerfile is as follows:

```dockerfile
FROM theflash2k/pwn-chal:latest

ENV CHAL_NAME=baby-pwn
COPY ${CHAL_NAME} ${CHAL_NAME}
COPY flag.txt flag.txt
```

| **NOTE**: Challenge binary **MUST** be placed inside the `/app` directory. Default WORKDIR is set to `/app`

The binaries will run in the context of user `ctf-player` rather than root.
| This CAN be overriden with the use of OVERRIDE_USER environment variable

Following environment variables can be changed to your own likings:
```bash
CHAL_NAME
PORT
BASE
START_DIR
FLAG_FILE
LOG_FILE
OVERRIDE_USER
SETUID_USER
```

### CHAL_NAME
This is the name of the challenge binary. (I know, should've been `CHAL_BIN` or something, but ;-;).

### PORT
The port that the challenge will listen on internally. The default port is `8000`

### BASE
The BASE binary to use for listening. Can be one of the following:
1. ynetd [Default]
2. socat

### START_DIR
In case the challenge gives a shell, this is the directory the user will land in. Default is `/app`.

### FLAG_FILE
User can specify the path to the flag file. Needs to be an absolute value as the container will set `chattr +i` on this file. Default is `/app/flag.txt`. In case the flag_file is random, chattr won't work place but file will exist.

| **NOTE**: There is a `FLAG_FILE_SYMLINK` environment variable, which isn't set by default, but if set, will generate a symlink for the flag in `/app/flag.txt` if `FLAG_FILE` is not `/app/flag.txt`.

### LOG_FILE
The absolute path of the file in which the logs will be stored. If not path is specified, only a file name; the logs will be stored in `/app/<file-name>`

### OVERRIDE_USER
By default, the binaries will run in the context of `ctf-player` user. This can be overriden by `OVERRIDE_USER` variable. It can be a valid user. But, if the user doesn't exist, it will default to `root`.

### SETUID_USER
This environment variable will change owner and group of `CHAL_NAME` to `SETUID_USER` and then give it `suid` permissions. And will run as `OVERRIDE_USER`. Permission set is `4755`. if `SETUID_USER` doesn't exist, it will default to `root`.

---

Environment variables may also be specified with the docker run command:
```bash
docker run -it --rm -e PORT=5012 -p 54251:5012 -e BASE=socat theflash2k/pwn-chal:latest
```

| **NOTE**: If no `CHAL_NAME` is provided, the default binary will run on the specified port and upon connecting, you'll get the following message:

```
pwn-chal container successfully deployed. Please setup your challenge by specifying the CHAL_NAME environment variable and placing your binary in /app.
Regards,
TheFlash2k
```

## Tags:

| Tag | Version |
| --- | --- |
| latest | Ubuntu 22.04 |
| python | Ubuntu 20.04 + Python3.8 |
| cpp | Ubuntu 22.04 + g++ |
| arm | Ubuntu 22.04 for arm with QEMU |
