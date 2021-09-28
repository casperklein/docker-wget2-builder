# docker-wget2-builder

Builds a [wget2](https://github.com/rockdaboot/wget2) debian package with Docker. Tested on amd64, arm64 and armhf architectures.

## Prepare

To clone this repository run:

    git clone https://github.com/casperklein/docker-wget2-builder docker-wget2-builder
    cd docker-wget2-builder

## Build wget2 debian package

Build wget2, package and copy it to the current directory with:

    make

## Install wget2 debian package

    make install

## Uninstall wget2

    make uninstall

## Cleanup build environment

    make clean
