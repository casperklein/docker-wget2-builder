# all targets are phony (no files to check)
.PHONY: default build clean install uninstall

default: build

build:
	./build.sh

clean:
	APP=$$(grep APP= Dockerfile | cut -d'"' -f2) && \
	VERSION=$$(grep VERSION= Dockerfile | cut -d'"' -f2) && \
	rm -vf $${APP}_$${VERSION}-1*.deb && \
	docker rmi casperklein/$$APP-builder:$$VERSION

install:
	APP=$$(grep APP= Dockerfile | cut -d'"' -f2) && \
	VERSION=$$(grep VERSION= Dockerfile | cut -d'"' -f2) && \
	dpkg -i $${APP}_$${VERSION}-1*.deb

uninstall:
	apt-get purge $$APP
