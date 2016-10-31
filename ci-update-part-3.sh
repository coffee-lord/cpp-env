#!/bin/sh -ue

echo 'EXECUTING PART 3'

ln -sf $LLVM_SDK_ROOT/stage/bin/ld.lld /usr/bin/ld

cd $LLVM_SDK_ROOT
sed -i -e 's/^UPDATE_GIT=.*$/UPDATE_GIT=0/g' -e 's/^IS_REBUILD=.*$/IS_REBUILD=1/g' build.sh
./build.sh || exit 1
cd /tmp/llvm
ninja install

cd ~
rm -rf /tmp/llvm
rm -rf $LLVM_SDK_ROOT/src
