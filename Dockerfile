ARG	version=10
FROM	debian:$version-slim

ENV	USER="casperklein"
ENV	NAME="wget2-builder"
ENV	VERSION="1.99.2"
ENV	APP="wget2"
ENV	GROUP="web"

ENV	GIT_REPO="https://github.com/rockdaboot/wget2"
ENV	GIT_COMMIT="af9703a93c922598db1f3180eb928485092b2f1c"

ENV	PACKAGES="wget make git autoconf autogen automake autopoint libtool-bin python rsync tar texinfo pkg-config doxygen pandoc gettext libbz2-dev flex lzip lcov libiconv-hook-dev zlib1g-dev liblzma-dev libbrotli-dev libzstd-dev libgnutls28-dev libidn2-dev libpsl-dev libnghttp2-dev libmicrohttpd-dev libpcre2-dev"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN	apt-get update \
&&	apt-get -y install $PACKAGES

# Build wget2
WORKDIR	/$NAME
RUN	git init			# make a new blank repository
RUN	git remote add origin $GIT_REPO	# add a remote
RUN	git fetch origin $GIT_COMMIT	# fetch commit of interest
RUN	git reset --hard FETCH_HEAD	# reset this repository's master branch to the commit of interest
RUN	./bootstrap			# requires git
RUN	./configure --prefix=/usr
RUN	make
RUN	echo 'GNU Wget2 is the successor of GNU Wget, a file and recursive website downloader.' > description-pak

# Copy root filesystem
COPY	rootfs /

# Create debian package with checkinstall
RUN	MASCHINE=$(uname -m);   \
	case "$MASCHINE" in     \
	x86_64)                 \
		ARCH="amd64"    \
		;;              \
	aarch64)                \
		ARCH="arm64"    \
		;;              \
	*)                      \
		ARCH="armhf"    \
		;;              \
	esac;                   \
	apt-get -y --no-install-recommends install file dpkg-dev && dpkg -i /checkinstall_1.6.2-4_$ARCH.deb
RUN	checkinstall -y --install=no \
			--pkgname=$APP \
			--pkgversion=$VERSION \
			--maintainer=$USER@$NAME \
			--pkggroup=$GROUP

# Move tmux debian package to /mnt on container start
CMD	mv ${APP}_${VERSION}-1_*.deb /mnt
