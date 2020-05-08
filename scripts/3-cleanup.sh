#!/bin/bash -xue

apt-get -y clean
apt-get -y purge --auto-remove build-essential binutils libxml2-dev libedit-dev linux-headers-amd64

rm -rf /var/lib/apt
rm -rf /var/cache/apt
