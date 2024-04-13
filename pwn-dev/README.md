## PWN-DEV - Highly customized one-click deployable Ubuntu-based environment for Pwn challenge solving and development

[Dockerhub](https://hub.docker.com/r/theflash2k/pwn-dev)
[Github](https://github.com/TheFlash2k/my-containers/tree/main/pwn-dev)

You can use this image to easily drop into a specific pwn challenge environment that a certain challenge might require off of you.

In the project's [Github](https://github.com/TheFlash2k/my-containers/blob/main/pwn-dev/pwn-dev) repo, I also provide with the `pwn-dev` script that can be used to invoke any of the environment.

You can use the following command to setup the pwn-dev environment (assuming you're cloning rather than pulling from Dockerhub)

```bash
$ git clone https://github.com/theflash2k/my-containers /opt/my-containers
$ cd /opt/my-containers/pwn-dev
# if you don't have the containers built already, you can use make to manually build all the containers (This will take quite some time and resources as you'll be building 4 different containers)
$ make
$ ln -s $(pwd)/pwn-dev /usr/local/bin/pwn-dev
```

Now, to drop into the `pwn-dev` environment, you can use `pwn-dev` command. To check out the available versions:

```bash
pwn-dev --help
```

```bash
Usage: pwn-dev <version>
Available versions:
	 latest   <-- Default
	 2204
	 2004
	 1804
	 1604
```

By simply typing `pwn-dev` you'll be dropped into `pwn-dev:latest` which is based off of `ubuntu:22.04@sha256:f9d633ff6640178c2d0525017174a688e2c1aef28f0a0130b26bd5554491f0da`

You can specify the version as (example 1604):
```bash
pwn-dev 16
```

### | 1604 can be shortened to 16 and it will still work. Same for all the others.

### | If using the `pwn-dev` script, the current folder will be mounted at `/chal` and the `WORKDIR` by default is set to `/chal`, therefore you'll always land in your current directory in the container.

Following versions are currently available with the base images in pwn-dev:

| Version | Base Image |
| --- | --- |
| latest | ubuntu:22.04@sha256:f9d633ff6640178c2d0525017174a688e2c1aef28f0a0130b26bd5554491f0da |
| 2204 | ubuntu:22.04@sha256:f9d633ff6640178c2d0525017174a688e2c1aef28f0a0130b26bd5554491f0da |
| 2004 | ubuntu:20.04@sha256:80ef4a44043dec4490506e6cc4289eeda2d106a70148b74b5ae91ee670e9c35d |
| 1804 | ubuntu:18.04@sha256:152dc042452c496007f07ca9127571cb9c29697f42acbfad72324b2bb2e43c98 |
| 1604 | ubuntu:16.04@sha256:1f1a2d56de1d604801a9671f301190704c25d604a416f59e03c04f5c6ffee0d6 |

### Tools installed:
**Following tools are installed by default**:
- **zsh** (with `ohmyzsh` and `alanpeabody` theme)
- **gcc/g++/make/cmake**
- **ruby**
- **python3 (varies based on the based image. >= 3.6 installed.)**
- **strace/ltrace**
- **nasm**
- **tmux (with `ohmytmux`)**
- **7z**
- **gdb**

Open-Source/Pwn-related tools:
- **gdb plugins**:
   - **pwndbg**
   - **peda** (All except 16.04)
   - **gef** (All except 16.04)
- **pwninit**
- **seccomptool**
- **one_gadget**
- **rappel** (both x64 and x86) [to invoke x86: `rappel-x86`]

Python Libraries:
- **pwntools**
- **angr**
- **z3**
- **ROPGadget**
- **ropper**
- **IPython**
- **uncompyle6**
- **LIEF**
- **unicorn**
- **capstone**

My personal stuff:
- **Templates**
    - All my templates are in `/root/Templates`
- [**fmt-generator**](https://github.com/TheFlash2k/ctf-writeups/blob/main/_utils/generate.py)
- [**get-libc-from-dockerfile**](https://gist.githubusercontent.com/TheFlash2k/50008e1ba8b3e7e6169642e636996e51/raw/cd1cfca56a49e558a46da71d39db6755412f9a18/get-libc-from-dockerfile) # Probably one of my really useful scripts
- **str2hex** (Converts a string to a hexadecimal representation)
- **str2lehex** (Converts a string to a little-endian hexadecimal representation)
- **get-\***
    - These are three aliases that I use to quickly copy over a template from `~/Templates` to the current folder. These are:
        - **get-exploit** - Copies over `~/Templates/exploit.py` which is my generic script
        - **get-fmt** - Copies over `~/Templates/exploit-fmt.py` which is my format-string oriented template with functions already setup
        - **get-basic** - Copies over `~/Templates/exploit-basic.py` which the most basic exploit template I use with no fancy functions or anything.
