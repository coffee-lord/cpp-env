# Ubuntu Build Environment for C++

A docker image for building C++ packages.

## Features

* Full LLVM pipeline
* libc++
* libunwind
* compiler-rt
* Clang
* LLD linker
* Boost

## Variables

```sh
LLVM_SDK_ROOT=/opt/llvm
BOOST_ROOT=/opt/llvm-boost/stage

PATH=$LLVM_SDK_ROOT/bin-release:$LLVM_SDK_ROOT/stage/bin:/usr/bin:/bin

CXX=clang++
CC=clang
```
