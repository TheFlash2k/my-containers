#!/bin/bash

##### Modifiable variables ########
OVERRIDE_THEME="alanpeabody"      # zsh theme:
###################################

set -x

dpkg --add-architecture i386 && \
	apt update

# Installing LIBS
DEBIAN_FRONTEND=noninteractive \
	TZ=GB apt install -y \
	libc6:i386 \
	libc6-dbg:i386 \
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
	libc6-dbg \
	gcc \
	g++ \
	build-essential \
	python3 \
	python3-pip \
	strace \
	ltrace \
	nasm \
	unzip \
	man-db \
	net-tools \
	iputils-ping \
	netcat \
	socat \
	p7zip-full \
	cmake \
	autoconf \
	file \
	ruby \
	ruby-dev \
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
	rpm2cpio cpio \
	qemu \
	zsh

wget -O /tmp/bat.deb https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb
apt install -y /tmp/bat.deb
rm /tmp/bat.deb

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
	&& apt install -y python3.6 \
	&& curl https://bootstrap.pypa.io/pip/3.6/get-pip.py | python3.6 \
	&& ln -sf /usr/bin/python3.6 /usr/bin/python3
else
	pip3 install --upgrade \
	pip \
	setuptools \
	setuptools-rust \
	wheel
fi

# Installing python-based tools:
pip3 install --no-cache-dir \
	argparse \
	pwntools \
	prompt_toolkit \
	ropper \
	ROPGadget \
	angr \
	IPython \
	uncompyle6 \
    z3-solver \
    smmap2 \
    apscheduler \
    pebble \
    r2pipe

# Installing GDB plugins:
git clone https://github.com/scwuaptx/Pwngdb /opt/Pwngdb
if [[ "$VERSION" != "16.04" ]]; then
	git clone https://github.com/pwndbg/pwndbg /opt/pwndbg
	cd /opt/pwndbg
	git checkout 2023.03.19
	./setup.sh
	git clone https://github.com/longld/peda.git /opt/peda
	mkdir /opt/gef/
	wget -O /opt/gef/gef.py https://github.com/hugsy/gef/raw/main/gef.py
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

	# Add the PWNGDB Heap Info stuff:
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
else
	# Install only pwndbg for 16.04:
	wget -O /tmp/pwndbg.deb https://github.com/pwndbg/pwndbg/releases/download/2024.02.14/pwndbg_2024.02.14_amd64.deb
	dpkg -i /tmp/pwndbg.deb
	rm -f /tmp/pwndbg.deb
	cp /usr/bin/pwndbg /usr/bin/gdb
	sed -i 's/dir=.*/dir=\/usr\/lib\/pwndbg/g' /usr/bin/gdb
fi

# Installing shit for aesthetics ;-;
chsh -s /usr/bin/zsh && \
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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

wget -O /usr/bin/pwninit https://github.com/io12/pwninit/releases/download/3.3.1/pwninit
chmod +x /usr/bin/pwninit

# My own custom tools that I use:
echo -n "IyEvYmluL2Jhc2gKCmlmIFtbICQjICE9IDEgXV07IHRoZW4KCWVjaG8gIlVzYWdlOiAkMCA8c3RyaW5nPiIKCWV4aXQgMQpmaQoKZnVuY3Rpb24gZW5kaWFuKCkgewoJaWYgW1sgLXogJDEgXV07IHRoZW4gZWNobyAiTm8gaW5wdXQgc3VwcGxpZWQuIjsgZXhpdCAxOyBmaQoJdj0kMQoJaT0keyN2fQoJd2hpbGUgWyAkaSAtZ3QgMCBdOyBkbwoJCWk9JFskaS0yXQoJCWVjaG8gLW4gJHt2OiRpOjJ9Cglkb25lCn0KCl9oZXg9JChlY2hvIC1uICIkMSIgfCBvZCAtQSBuIC10IHgxIHwgdHIgLWQgIiAiKQpfbGl0dGxlPSQoZW5kaWFuICRfaGV4KQoKZWNobyAiU3RyaW5nOiAkMSIKZWNobyAiQmFzZTogJF9oZXgiCmVjaG8gIkxpdHRsZSBlbmRpYW46ICRfbGl0dGxlIgo=" | base64 -d  > /usr/bin/str2hex
echo -n "IyEvdXNyL2Jpbi9lbnYgcHl0aG9uMwpmcm9tIHN5cyBpbXBvcnQgYXJndgoKaWYgbGVuKGFyZ3YpIDwgMjoKCXByaW50KGYiVXNhZ2U6IHthcmd2WzBdfSA8c3RyaW5nIHRvIGNvbnZlcnQgdG8gTGl0dGxlIEVuZGlhbiBIZXg+XG5OT1RFOiBJdCB3aWxsIGluIHBhaXIgb2YgOCIpCglleGl0KDEpCgpkZWYgc3RyMmxlaGV4KF9zdHI6IHN0cik6CglkZWYgdG9faGV4KGNodW5rOiBzdHIpOgoJCWNodW5rID0gY2h1bmtbOjotMV0KCQlyZXR1cm4gJzB4JyArICcnLmpvaW4oW2hleChvcmQoaSkpWzI6XSBmb3IgaSBpbiBjaHVua10pCgoJbW9kID0gbGFtYmRhIGEsIGI6IGEgJSBiIGlmIGEgPj0gYiBlbHNlIGIgJSBhCgljaHVua2lmeSA9IGxhbWJkYSBsc3QsIG46IFtsc3RbaTppICsgbl0gZm9yIGkgaW4gcmFuZ2UoMCwgbGVuKGxzdCksIG4pXQoKCXByZWZpeF9wYWRkaW5nID0gIi8iCglkYXRhID0gX3N0cgoKCV9zdHIgPSAocHJlZml4X3BhZGRpbmcgKiBtb2QobGVuKGRhdGEpLCA4KSkgKyBkYXRhCglfc3RyID0gY2h1bmtpZnkoX3N0ciwgOClbOjotMV0KCglydCA9IFtdCglmb3IgaSBpbiBfc3RyOgoJCXJ0LmFwcGVuZCh0b19oZXgoaSkpCglyZXR1cm4gcnQKCmRhdGEgPSAnICcuam9pbihhcmd2WzE6XSkKbGVzdHIgPSBzdHIybGVoZXgoZGF0YSkKCmZvciBpIGluIGxlc3RyOgoJcHJpbnQoaSk=" | base64 -d > /usr/bin/str2lehex
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

# Installing my exploit templates:
# Base64 might look sus but it was the most easiest way for me:
mkdir -p /root/Templates
ln -sf /root/Templates/generate.py /usr/bin/fmt-generator

echo -n "IyEvYmluL2Jhc2gKCmNwIH4vVGVtcGxhdGVzL2V4cGxvaXQucHkgZXhwbG9pdC5weQo=" | base64 -d > /usr/bin/get-exploit
echo -n "IyEvYmluL2Jhc2gKCmNwIH4vVGVtcGxhdGVzL2V4cGxvaXQtZm10LnB5IGV4cGxvaXQucHkK" | base64 -d > /usr/bin/get-fmt
chmod +x /usr/bin/get-*

# Delete after completing.
rm -- "$0"
