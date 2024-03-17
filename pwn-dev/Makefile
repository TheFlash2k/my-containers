all:
	$(BUILD)
	$(RUN)

build:
	docker build -t theflash2k/pwn-dev:latest .
	docker tag theflash2k/pwn-dev:latest theflash2k/pwn-dev:22.04

20:
	docker build -t theflash2k/pwn-dev:20.04 -f Dockerfile.2004 .

18:
	docker build -t theflash2k/pwn-dev:18.04 -f Dockerfile.1804 .

22:
	docker build -t theflash2k/pwn-dev:22.04 .
	docker tag theflash2k/pwn-dev:22.04 theflash2k/pwn-dev:latest

run:
	# This will run as a privileged container, beware; huehuehue
	docker run \
	-it \
	--rm \
	--name pwn-dev \
	--hostname pwn-dev \
	-v `pwd`:/chal \
	--privileged \
	theflash2k/pwn-dev

stop:
	docker stop pwn-dev

clean:
	docker rmi pwn-dev --force
