#!/bin/sh -ue

echo 'EXECUTING PART 2'

cd $LLVM_SDK_ROOT
sed -i 's/-march=native -mtune=native//g' build.sh common.sh

sed -i -e 's/^UPDATE_GIT=.*$/UPDATE_GIT=1/g' -e 's/^IS_REBUILD=.*$/IS_REBUILD=0/g' build.sh
./build.sh || exit 1
cd /tmp/llvm
ninja install

cd ~
rm -rf /tmp/llvm

apt-get -y purge --auto-remove clang
