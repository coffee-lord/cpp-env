#!/bin/sh -ue

echo 'EXECUTING PART 6'

cd ~

CMAKE_INSTALL_FILE=cmake-3.8.1-Linux-x86_64.sh
curl -k -L --compressed 'https://cmake.org/files/v3.8/cmake-3.8.1-Linux-x86_64.sh' > $CMAKE_INSTALL_FILE
chmod +x $CMAKE_INSTALL_FILE
./$CMAKE_INSTALL_FILE --prefix=/usr --exclude-subdir
rm $CMAKE_INSTALL_FILE
