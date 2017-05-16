#!/bin/sh -ue

LLVM_SDK_ROOT=/opt/llvm
BOOST_ROOT=/opt/llvm-boost

rsync -av $(find $LLVM_SDK_ROOT -maxdepth 1 -name 'bin-*') $LLVM_SDK_ROOT/cmake $(find $LLVM_SDK_ROOT -maxdepth 1 -name '*.sh') $PWD/opt/llvm
rsync -av $(find $BOOST_ROOT -maxdepth 1 -name '*.sh') $PWD/opt/llvm-boost
