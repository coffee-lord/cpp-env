#!/bin/sh -ue

echo 'EXECUTING PART 1'

apt-get update

# apt-get dist-upgrade -y -m --no-install-recommends

apt-get install -y -m --no-install-recommends \
cmake \
build-essential \
curl \
unzip \
libpthread-stubs0-dev \
python3 \
libedit-dev \
ninja-build \
python3-pip \
libncurses5-dev \
libxml2-dev \
subversion \
clang \
python3-setuptools \
python3-wheel \
libedit2 \
linux-headers-amd64
