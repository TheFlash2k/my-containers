all:
	$(BUILD)
	$(RUN)

build:
	docker build -t theflash2k/pwn-dev:latest .

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
