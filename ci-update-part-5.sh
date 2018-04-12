#!/bin/sh -ue

echo 'EXECUTING PART 6'

cd ~

curl -k -L --compressed 'https://cmake.org/files/v3.10/cmake-3.10.0-Linux-x86_64.sh' > cmake.sh
chmod +x cmake.sh
./cmake.sh --prefix=/usr --exclude-subdir
rm cmake.sh
