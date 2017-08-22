#!/bin/sh -ue

echo 'EXECUTING PART 6'

cd ~

curl -k -L --compressed 'https://cmake.org/files/v3.9/cmake-3.9.1-Linux-x86_64.tar.gz' > cmake.sh
chmod +x cmake.sh
./cmake.sh --prefix=/usr --exclude-subdir
rm cmake.sh
