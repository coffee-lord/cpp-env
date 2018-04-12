#!/bin/sh -ue

LLVM_SDK_ROOT=/opt/llvm

rsync -av $(find $LLVM_SDK_ROOT -maxdepth 1 -name 'bin-*') $LLVM_SDK_ROOT/cmake $(find $LLVM_SDK_ROOT -maxdepth 1 -name '*.sh') $PWD/opt/llvm
