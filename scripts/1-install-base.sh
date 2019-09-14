#!/bin/bash -xue

apt-get update
apt-get dist-upgrade -y
apt-get install -y --no-install-recommends \
	python3.7 \
	python3-pip \
	patchelf \
	build-essential \
	cmake \
	pkg-config \
	ninja-build \
	ccache \
	python3-setuptools \
	git \
	libedit-dev \
	curl \
	libpthread-stubs0-dev \
	libncurses5-dev \
	libxml2-dev \
	linux-headers-amd64 \
	libedit2 \
	unzip
