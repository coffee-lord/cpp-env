#!/bin/sh -ue

echo 'EXECUTING PART 1'

apt-get update
apt-get dist-upgrade -y

apt-get install -y --no-install-recommends \
cmake \
build-essential \
git \
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
