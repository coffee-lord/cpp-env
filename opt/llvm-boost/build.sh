#!/bin/sh -xue

LLVM_ROOT=/opt/llvm
BOOST_ROOT=/opt/llvm-boost/stage

export PATH="$LLVM_ROOT/bin-release:$LLVM_ROOT/stage/bin:/usr/bin:/bin"

export CC=$LLVM_ROOT/bin-release/clang
export CXX=$LLVM_ROOT/bin-release/clang++
export AR=$LLVM_ROOT/stage/bin/llvm-ar
export NM=$LLVM_ROOT/stage/bin/llvm-nm
export RANLIB=$LLVM_ROOT/stage/bin/llvm-ranlib
export OPTIM_SIZE=1

build_boost() {
./b2 \
--prefix=$BOOST_ROOT \
--build-dir=/tmp/boost \
toolset=clang \
variant=release \
link=shared,static \
threading=multi \
runtime-link=shared \
--ignore-site-config \
--without-python \
--without-mpi \
--without-fiber \
cxxflags="-std=c++14" \
linkflags="-Wl,-rpath=$BOOST_ROOT/lib" \
-j5 $@
}

rm -rf /tmp/boost
./bootstrap.sh --prefix=$BOOST_ROOT --with-toolset=clang
build_boost
build_boost install
