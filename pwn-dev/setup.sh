#!/bin/bash

##### Modifiable variables ########
OVERRIDE_THEME="alanpeabody"      # zsh theme:
###################################

set -x

dpkg --add-architecture i386 && \
	apt update

if [[ "$VERSION" == "24.04" ]]; then
	ncurses="libncurses6"
else
	ncurses="libncurses5"
fi

# Installing LIBS
DEBIAN_FRONTEND=noninteractive \
	TZ=GB apt install -y \
	libc6:i386 libc6-dbg:i386 libstdc++6:i386 libedit-dev:i386 libseccomp-dev:i386 "$ncurses:i386" \
	"$ncurses" libbrlapi-dev libntirpc-dev libpam0g-dev liblzma-dev liblzo2-dev libedit-dev \
	libc6-dbg libcapstone-dev libseccomp-dev libpython3-dev libssl-dev libffi-dev libsqlite3-dev \
	ruby-dev zlib1g-dev gcc g++ build-essential python3 python3-pip strace ltrace nasm yasm \
	unzip man-db net-tools iputils-ping netcat-traditional socat p7zip-full cmake autoconf \
	file ruby ruby-dev g++-multilib gcc-multilib curl wget git patchelf gdb gdb-multiarch \
	dos2unix elfutils binutils-* tmux nano rpm2cpio cpio qemu-system qemu-user qemu-user-static \
	qemu-kvm libc6-arm64-cross libc6-dbg-arm64-cross libc6-armhf-cross libc6-dbg-armhf-cross \
	autoconf automake libtool flex bison zsh vim

wget -O /tmp/bat.deb https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb
DEBIAN_FRONTEND=noninteractive \
	TZ=GB apt install -y \
	/tmp/bat.deb

DEBIAN_FRONTEND=noninteractive \
	TZ=GB apt install -y \
	libstdc++6-arm64-cross libstdc++6-armhf-cross \
	gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf \
	g++-aarch64-linux-gnu g++-arm-linux-gnueabihf

# Set the --break-system-packages if VERSION >= 23.04
[[ "$VERSION" == "23.04" || "$VERSION" == "24.04" ]] && PIP_ARGS="--break-system-packages"

# python3.6 is bare minimum for most tools to work.
if [[ "$VERSION" == "16.04" ]]; then
	# Install ruby if UBUNTU 16:
	git clone https://github.com/postmodern/ruby-install /opt/ruby-install
	cd /opt/ruby-install
	make install
	ruby-install ruby 3.0.0
	_path="/opt/rubies/ruby-3.0.0/bin"
	for i in $(ls "$_path"); do ln -sf "$_path/$i" "/usr/bin/$i"; done

	apt install -y software-properties-common && \
	add-apt-repository -y ppa:jblgf0/python \
	&& apt clean -y \
	&& apt autoremove -y \
	&& apt remove -y python3 python3-pip ruby ruby-dev \
	&& apt autoremove -y \
	&& apt update \
	&& apt install -y python3.6 libpython3.6-dev \
	&& curl https://bootstrap.pypa.io/pip/3.6/get-pip.py | python3.6 \
	&& ln -sf /usr/bin/python3.6 /usr/bin/python3
else
	pip install --upgrade --no-cache-dir $PIP_ARGS \
	pip \
	setuptools \
	setuptools-rust \
	wheel
fi

# Installing python-based tools:
pip3 install --upgrade --no-cache-dir $PIP_ARGS \
	cmake argparse pwntools prompt_toolkit ropper \
	ROPGadget angr IPython uncompyle6 z3-solver smmap2 \
	apscheduler pebble r2pipe crccheck

# Installing GDB plugins:
git clone https://github.com/TheFlash2k/Pwngdb /opt/Pwngdb
git clone https://github.com/longld/peda.git /opt/peda

if [[ "$VERSION" != "16.04" ]]; then
	git clone https://github.com/pwndbg/pwndbg /opt/pwndbg
	cd /opt/pwndbg
	./setup.sh
else
	# Install only pwndbg for 16.04:
	wget -O /tmp/pwndbg.deb https://github.com/pwndbg/pwndbg/releases/download/2024.02.14/pwndbg_2024.02.14_amd64.deb
	dpkg -i /tmp/pwndbg.deb
	rm -f /tmp/pwndbg.deb
	cp /usr/bin/pwndbg /usr/bin/gdb
	sed -i 's/dir=.*/dir=\/usr\/lib\/pwndbg/g' /usr/bin/gdb
fi

cat >> ~/.gdbinit <<EOF
define init-peda
	source /opt/peda/peda.py
end
document init-peda
	Initializes the PEDA (Python Exploit Development Assistant for GDB) framework
end

define init-pwndbg
	source /opt/pwndbg/gdbinit.py
end
document init-pwndbg
	Initializes PwnDBG
end

define init-gef
	source /root/.gdbinit-gef.py
end
document init-gef
	Initializes GEF (GDB Enhanced Features)
end

# Add the PWNGDB Heap Info stuff:
source /opt/Pwngdb/pwngdb.py
source /opt/Pwngdb/angelheap/gdbinit.py
define hook-run
python
import angelheap
angelheap.init_angelheap()
end
end
EOF

tools=( "peda" "pwndbg" "gef" )
for tool in ${tools[@]}; do
	echo "exec gdb -q -ex init-$tool \"\$@\"" | tee /usr/bin/gdb-$tool
	echo "exec gdb -q -ex init-$tool \"\$@\"" | tee /usr/bin/$tool
	chmod +x /usr/bin/gdb-$tool /usr/bin/$tool
done

## Install bata23 gef
init_gef="/root/.gdbinit-gef.py"
git clone https://github.com/bata24/gef /opt/gef
wget -q https://raw.githubusercontent.com/bata24/gef/dev/gef.py -O "$init_gef"
sed -i $((`grep -n 'too old' "$init_gef" | awk -F ':' '{ print $1 }'`+1))d "$init_gef"

## Rust:
curl -o /tmp/rustup.sh https://sh.rustup.rs -sSf
bash /tmp/rustup.sh -y

## Ninja:
git clone https://github.com/ninja-build/ninja /opt/ninja
cd /opt/ninja
./configure.py --bootstrap
mv ninja /usr/bin/
cd /opt/ && rm -rf /opt/ninja

## RP++
if [[ "$VERSION" == "16.04" || "$VERSION" == "18.04" ]]; then
	wget -O /usr/bin/rp-lin https://github.com/0vercl0k/rp/releases/download/v1/rp-lin-x64
	chmod +x /usr/bin/rp-lin
	cp /usr/bin/rp-lin /usr/bin/rp++
else
	git clone https://github.com/0vercl0k/rp /opt/rp
	cd /opt/rp/src/build
	chmod u+x ./build-release.sh && ./build-release.sh
	mv /opt/rp/src/build/rp-lin /usr/bin/rp++
	cp /usr/bin/rp++ /usr/bin/rp-lin
	cd /opt && rm -rf /opt/rp
fi

#### kexec-tools
git clone https://github.com/horms/kexec-tools /opt/kexec-tools
cd /opt/kexec-tools
./bootstrap
./configure --prefix=/usr/local
make install

# Kernel stuff
pip3 install $PIP_ARGS --upgrade lz4 zstandard git+https://github.com/clubby789/python-lzo@b4e39df
pip3 install $PIP_ARGS --upgrade git+https://github.com/marin-m/vmlinux-to-elf

# Installing shit for aesthetics ;-;
chsh -s /usr/bin/zsh && \
	wget -O /tmp/install.sh \
		https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
	sh /tmp/install.sh

cd /root/
if [[ "$VERSION" != "16.04" ]]; then
	git clone https://github.com/gpakosz/.tmux.git && \
		ln -s -f .tmux/.tmux.conf && \
		cp .tmux/.tmux.conf.local .
fi
sed -i "s/ZSH_THEME=\".*\"/ZSH_THEME=\"$OVERRIDE_THEME\"/g" /root/.zshrc

gem install \
	heapinfo \
	one_gadget \
	seccomp-tools:1.5.0

wget -O /usr/bin/pwninit \
	https://github.com/io12/pwninit/releases/download/3.3.1/pwninit
chmod +x /usr/bin/pwninit

echo "CTF{F4k3_fl4g_f0r_t3sting}" > /flag
cp /flag /flag.txt
cp /flag /root/flag.txt
cp /flag /root/flag
chmod +x /usr/bin/{get-libc-from-dockerfile,str2hex,str2lehex}
 
# Installing Rappel:
git clone https://github.com/yrp604/rappel /opt/rappel
cd /opt/rappel
make
mv ./bin/rappel /usr/bin/
make clean
ARCH=x86 make
mv ./bin/rappel /usr/bin/rappel-x86

# Setup ARM stuff:
mkdir /etc/qemu-binfmt
ln -s /usr/aarch64-linux-gnu /etc/qemu-binfmt/aarch64 
ln -s /usr/arm-linux-gnueabihf /etc/qemu-binfmt/arm

# Custom aliases:
## Fix the permissions of file from root to 1000:1000
echo "alias fixperms=\"chown 1000:1000\"" >> ~/.zshrc
## Exploit templates:
echo "alias get-exploit=\"cp /root/Templates/exploit.py .\""    >> ~/.zshrc
echo "alias get-fmt=\"cp /root/Templates/exploit-fmt.py .\""    >> ~/.zshrc
echo "alias fmt-generator=\"cp /root/Templates/generate.py .\"" >> ~/.zshrc

# Delete all the caches:
rm -rf /tmp/* ~/.cache /var/lib/apt/lists/*
apt clean
apt autoclean
# Remove the extra stuff:
rm -rf \
	/root/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc/ \
	/opt/{rappel,ninja,kexec-tools,rp,ruby-install} \
	/usr/local/src/ruby*

# Delete after completing.
rm -- "$0"
