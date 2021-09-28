FROM	debian:11-slim

ENV	GIT_USER="rockdaboot"
ENV	GIT_REPO="wget2"
ENV	GIT_COMMIT="v2.0.0"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"

ENV	PACKAGES="file checkinstall dpkg-dev make git ca-certificates wget autoconf autogen automake autopoint libtool-bin python rsync tar texinfo pkg-config doxygen pandoc gettext libbz2-dev flex lzip lcov libiconv-hook-dev zlib1g-dev liblzma-dev libbrotli-dev libzstd-dev libgnutls28-dev libidn2-dev libpsl-dev libnghttp2-dev libmicrohttpd-dev libpcre2-dev"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
ENV	DEBIAN_FRONTEND=noninteractive
RUN	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y --no-install-recommends install $PACKAGES \
&&	rm -rf /var/lib/apt/lists/*

# Download source
#WORKDIR	/$GIT_REPO
#ADD	$GIT_ARCHIVE /
#RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz

# Build wget2
ARG	MAKEFLAGS=""
RUN	git clone https://github.com/$GIT_USER/$GIT_REPO $GIT_REPO # ./bootstrap requires to run in a git directory
WORKDIR	/$GIT_REPO
RUN	./bootstrap			\
&&	./configure --prefix=/usr	\
&&	make				\
&&	make check

# Create debian package with checkinstall
ENV	APP="wget2"
ENV	MAINTAINER="casperklein@docker-wget2-builder"
ENV	GROUP="web"
ARG	VERSION
RUN	echo 'GNU Wget2 is the successor of GNU Wget, a file and recursive website downloader.' > description-pak \
&&	checkinstall -y --install=no			\
			--pkgname=$APP			\
			--pkgversion=$VERSION		\
			--maintainer=$MAINTAINER	\
			--pkggroup=$GROUP

# Move debian package to /mnt on container start
CMD	["bash", "-c", "mv ${APP}_*.deb /mnt"]
