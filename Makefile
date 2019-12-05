# all targets are phony (no files to check)
.PHONY: default build clean install uninstall

USER := $(shell grep -P 'ENV\s+USER=".+?"' Dockerfile | cut -d'"' -f2)
NAME := $(shell grep -P 'ENV\s+NAME=".+?"' Dockerfile | cut -d'"' -f2)
VERSION := $(shell grep -P 'ENV\s+VERSION=".+?"' Dockerfile | cut -d'"' -f2)

default: build

build:
	./build.sh

clean:
	rm -f wget2_$(VERSION)-1*.deb
	docker rmi $(USER)/$(NAME):$(VERSION)

install:
	apt-get -y install libbrotli1
	dpkg -i wget2_$(VERSION)-1*.deb

uninstall:
	apt-get purge wget2
	apt-get purge libbrotli1
