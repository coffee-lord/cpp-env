#!/bin/sh -xue

LLVM_SDK_ROOT=/opt/llvm
BOOST_ROOT=/opt/llvm-boost/stage

export PATH="$LLVM_SDK_ROOT/bin-release:$LLVM_SDK_ROOT/stage/bin:/usr/bin:/bin"
export CC="clang"
export CXX="clang++"

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
