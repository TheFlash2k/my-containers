#!/bin/bash

set -ex

dpkg --add-architecture i386 && \
	apt update

# Installing LIBS
DEBIAN_FRONTEND=noninteractive \
	TZ=GB apt install -y \
	libc6:i386 \
	libncurses5:i386 \
	libstdc++6:i386 \
	libedit-dev:i386 \
	libseccomp-dev:i386 \
	liblzma-dev \
	liblzo2-dev \
	libedit-dev \
	zlib1g-dev \
	libcapstone-dev \
	libseccomp-dev \
	libssl-dev \
	libffi-dev \
	ruby-dev \
	gcc \
	g++ \
	build-essential \
	python3 \
	python3-pip \
	ruby \
	strace \
	ltrace \
	nasm \
	unzip \
	man-db \
	p7zip-full \
	cmake \
	autoconf \
	file \
	g++-multilib \
	gcc-multilib \
	curl \
	wget \
	git \
	patchelf \
	gdb \
	dos2unix \
	elfutils \
	binutils-* \
	tmux \
	nano \
	radare2 \
	zsh

# python3.6 is bare minimum for most tools to work.
if [[ "$VERSION" == "16.04" ]]; then 
	apt install -y software-properties-common && \
	add-apt-repository -y ppa:jblgf0/python \
	&& apt clean -y \
	&& apt autoremove -y \
	&& apt remove -y python3 python3-pip ruby ruby-dev \
	&& apt autoremove -y \
	&& apt update \
	&& apt install -y python3.6 \
	&& curl https://bootstrap.pypa.io/pip/3.6/get-pip.py | python3.6
else
	pip3 install --upgrade \
	pip \
	setuptools \
	setuptools-rust \
	wheel
fi

# Installing python-based tools:
pip3 install \
	argparse \
	pwntools \
	prompt_toolkit \
	ropper \
	ROPGadget \
	angr \
	IPython \
	uncompyle6

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
	source /opt/gef/gef.py
	end
	document init-gef
	Initializes GEF (GDB Enhanced Features)
	end
	# Default to pwndbg:
	document init-pwndbg
EOF

tools=( "peda" "pwndbg" "gef" )
for tool in ${tools[@]}; do
	echo "exec gdb -q -ex init-$tool \"\$@\"" | tee /usr/bin/gdb-$tool
	echo "exec gdb -q -ex init-$tool \"\$@\"" | tee /usr/bin/$tool
	chmod +x /usr/bin/gdb-$tool /usr/bin/$tool
done

# Installing GDB plugins:
if [[ "$VERSION" != "16.04" ]]; then
	git clone https://github.com/pwndbg/pwndbg /opt/pwndbg
	cd /opt/pwndbg
	git checkout 2023.03.19
	./setup.sh
	git clone https://github.com/longld/peda.git /opt/peda
	mkdir /opt/gef/
	wget -O /opt/gef/gef.py https://github.com/hugsy/gef/raw/main/gef.py
else
	# Install only pwndbg for 16.04:
	wget -O /tmp/pwndbg.deb https://github.com/pwndbg/pwndbg/releases/download/2024.02.14/pwndbg_2024.02.14_amd64.deb
	dpkg -i /tmp/pwndbg.deb
	rm -f /tmp/pwndbg.deb
	cp /usr/bin/pwndbg /usr/bin/gdb
	sed -i 's/dir=.*/dir=\/usr\/lib\/pwndbg/g' /usr/bin/gdb

	# Install ruby:
	git clone https://github.com/postmodern/ruby-install /opt/ruby-install
	cd /opt/ruby-install
	make install
	ruby-install ruby 3.0.0
	_path="/opt/rubies/ruby-3.0.0/bin"
	for i in $(ls "$_path"); do ln -sf "$_path/$i" "/usr/bin/$i"; done
fi

# Installing shit for aesthetics ;-;
chsh -s /usr/bin/zsh && \
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/gpakosz/.tmux.git && \
	ln -s -f .tmux/.tmux.conf && \
	cp .tmux/.tmux.conf.local .

# Installing other important tools:
	gem install \
		heapinfo \
		one_gadget \
		seccomp-tools:1.5.0

wget -O /usr/bin/pwninit https://github.com/io12/pwninit/releases/download/3.3.1/pwninit
chmod +x /usr/bin/pwninit

# Installing Rappel:
git clone https://github.com/yrp604/rappel /opt/rappel
cd /opt/rappel
make
mv ./bin/rappel /usr/bin/
make clean
ARCH=x86 make
mv ./bin/rappel /usr/bin/rappel-x86