#!/bin/bash

##### Modifiable variables ########
OVERRIDE_THEME="alanpeabody"      # zsh theme:
###################################

set -ex

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
	zsh

# Install ruby:
git clone https://github.com/postmodern/ruby-install /opt/ruby-install
cd /opt/ruby-install
make install
ruby-install ruby 3.0.0
_path="/opt/rubies/ruby-3.0.0/bin"
for i in $(ls "$_path"); do ln -sf "$_path/$i" "/usr/bin/$i"; done

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
fi

# Installing shit for aesthetics ;-;
chsh -s /usr/bin/zsh && \
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cd /root/
git clone https://github.com/gpakosz/.tmux.git && \
	ln -s -f .tmux/.tmux.conf && \
	cp .tmux/.tmux.conf.local .
sed -i "s/ZSH_THEME=\".*\"/ZSH_THEME=\"$OVERRIDE_THEME\"/g" /root/.zshrc

# Installing other important tools:
gem install \
	heapinfo \
	one_gadget \
	seccomp-tools

wget -O /usr/bin/pwninit https://github.com/io12/pwninit/releases/download/3.3.1/pwninit
chmod +x /usr/bin/pwninit

# My own custom tools that I use:
wget -O /usr/bin/get-libc-from-dockerfile https://gist.githubusercontent.com/TheFlash2k/50008e1ba8b3e7e6169642e636996e51/raw/cd1cfca56a49e558a46da71d39db6755412f9a18/get-libc-from-dockerfile
echo -n "IyEvYmluL2Jhc2gKCmlmIFtbICQjICE9IDEgXV07IHRoZW4KCWVjaG8gIlVzYWdlOiAkMCA8c3RyaW5nPiIKCWV4aXQgMQpmaQoKZnVuY3Rpb24gZW5kaWFuKCkgewoJaWYgW1sgLXogJDEgXV07IHRoZW4gZWNobyAiTm8gaW5wdXQgc3VwcGxpZWQuIjsgZXhpdCAxOyBmaQoJdj0kMQoJaT0keyN2fQoJd2hpbGUgWyAkaSAtZ3QgMCBdOyBkbwoJCWk9JFskaS0yXQoJCWVjaG8gLW4gJHt2OiRpOjJ9Cglkb25lCn0KCl9oZXg9JChlY2hvIC1uICIkMSIgfCBvZCAtQSBuIC10IHgxIHwgdHIgLWQgIiAiKQpfbGl0dGxlPSQoZW5kaWFuICRfaGV4KQoKZWNobyAiU3RyaW5nOiAkMSIKZWNobyAiQmFzZTogJF9oZXgiCmVjaG8gIkxpdHRsZSBlbmRpYW46ICRfbGl0dGxlIgo=" | base64 -d  > /usr/bin/str2hex
echo -n "IyEvdXNyL2Jpbi9lbnYgcHl0aG9uMwpmcm9tIHN5cyBpbXBvcnQgYXJndgoKaWYgbGVuKGFyZ3YpIDwgMjoKCXByaW50KGYiVXNhZ2U6IHthcmd2WzBdfSA8c3RyaW5nIHRvIGNvbnZlcnQgdG8gTGl0dGxlIEVuZGlhbiBIZXg+XG5OT1RFOiBJdCB3aWxsIGluIHBhaXIgb2YgOCIpCglleGl0KDEpCgpkZWYgc3RyMmxlaGV4KF9zdHI6IHN0cik6CglkZWYgdG9faGV4KGNodW5rOiBzdHIpOgoJCWNodW5rID0gY2h1bmtbOjotMV0KCQlyZXR1cm4gJzB4JyArICcnLmpvaW4oW2hleChvcmQoaSkpWzI6XSBmb3IgaSBpbiBjaHVua10pCgoJbW9kID0gbGFtYmRhIGEsIGI6IGEgJSBiIGlmIGEgPj0gYiBlbHNlIGIgJSBhCgljaHVua2lmeSA9IGxhbWJkYSBsc3QsIG46IFtsc3RbaTppICsgbl0gZm9yIGkgaW4gcmFuZ2UoMCwgbGVuKGxzdCksIG4pXQoKCXByZWZpeF9wYWRkaW5nID0gIi8iCglkYXRhID0gX3N0cgoKCV9zdHIgPSAocHJlZml4X3BhZGRpbmcgKiBtb2QobGVuKGRhdGEpLCA4KSkgKyBkYXRhCglfc3RyID0gY2h1bmtpZnkoX3N0ciwgOClbOjotMV0KCglydCA9IFtdCglmb3IgaSBpbiBfc3RyOgoJCXJ0LmFwcGVuZCh0b19oZXgoaSkpCglyZXR1cm4gcnQKCmRhdGEgPSAnICcuam9pbihhcmd2WzE6XSkKbGVzdHIgPSBzdHIybGVoZXgoZGF0YSkKCmZvciBpIGluIGxlc3RyOgoJcHJpbnQoaSk=" | base64 -d > /usr/bin/str2lehex
echo "CTF{F4k3_fl4g_f0r_t3sting_f0r_73st1ng}" > /flag
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

echo -n "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" | base64 -d > /root/Templates/templates.zip
cd /root/Templates
unzip templates.zip
rm templates.zip
chmod +x /root/Templates/*.py
echo -n "IyEvYmluL2Jhc2gKCmNwIH4vVGVtcGxhdGVzL2V4cGxvaXQtYmFzaWMucHkgZXhwbG9pdC5weQo=" | base64 -d > /usr/bin/get-basic
echo -n "IyEvYmluL2Jhc2gKCmNwIH4vVGVtcGxhdGVzL2V4cGxvaXQucHkgZXhwbG9pdC5weQo=" | base64 -d > /usr/bin/get-exploit
echo -n "IyEvYmluL2Jhc2gKCmNwIH4vVGVtcGxhdGVzL2V4cGxvaXQtZm10LnB5IGV4cGxvaXQucHkK" | base64 -d > /usr/bin/get-fmt
chmod +x /usr/bin/get-*

# Delete after completing.
rm -- "$0"
