FROM	debian:12-slim

ARG	GIT_USER="rockdaboot"
ARG	GIT_REPO="wget2"
ARG	GIT_COMMIT="v2.1.0"
#ARG	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"

ARG	PACKAGES="file checkinstall dpkg-dev make git ca-certificates wget autoconf autogen automake autopoint libtool-bin python3 rsync tar texinfo pkg-config doxygen pandoc gettext libbz2-dev flex lzip lcov libiconv-hook-dev zlib1g-dev liblzma-dev libbrotli-dev libzstd-dev libgnutls28-dev libidn2-dev libpsl-dev libnghttp2-dev libmicrohttpd-dev libpcre2-dev"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
ARG	DEBIAN_FRONTEND=noninteractive
RUN	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y --no-install-recommends install $PACKAGES \
&&	rm -rf /var/lib/apt/lists/*

# Build wget2
ARG	MAKEFLAGS=""
RUN	git clone https://github.com/$GIT_USER/$GIT_REPO $GIT_REPO # ./bootstrap requires to run in a git directory
WORKDIR	/$GIT_REPO
RUN	git checkout "$GIT_COMMIT"
RUN	./bootstrap			\
&&	./configure --prefix=/usr	\
&&	make				\
&&	make check

# Create debian package with checkinstall
ENV	APP="wget2"
ARG	MAINTAINER="casperklein@docker-wget2-builder"
ARG	GROUP="web"
ARG	VERSION="unknown"
RUN	echo 'GNU Wget2 is the successor of GNU Wget, a file and recursive website downloader.' > description-pak \
# fstrans=no since debian12 -->  https://bugs.launchpad.net/ubuntu/+source/checkinstall/+bug/976380
&&	checkinstall -y --install=no --fstrans=no	\
			--pkgname=$APP			\
			--pkgversion=$VERSION		\
			--maintainer=$MAINTAINER	\
			--pkggroup=$GROUP		\
			--requires=libgnutls-dane0

# Move debian package to /mnt on container start
CMD	["bash", "-c", "mv ${APP}_*.deb /mnt"]

LABEL	org.opencontainers.image.description="Builds a wget2 debian package"
LABEL	org.opencontainers.image.source="https://github.com/casperklein/docker-wget2-builder/"
LABEL	org.opencontainers.image.title="docker-wget2-builder"
LABEL	org.opencontainers.image.version="$VERSION"
