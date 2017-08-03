#!/bin/bash -ue

python3 -m pip install --user --upgrade conan pip

CLANG_VERSION=$($LLVM_SDK_ROOT/stage/bin/clang -v 2>&1 | sed -n 's/.*clang version \(.\..\).*/\1/p')

export CONAN_USER_HOME=$(pwd)
conan remote add private https://api.bintray.com/conan/signal9/conan > /dev/null 2>&1 || true

cat > $CONAN_USER_HOME/.conan/settings.yml <<EOF
os:
    Linux:
arch: [x86_64]
compiler:
    clang:
        version: ["$CLANG_VERSION"]
        libcxx: [libc++]

build_type: [Release]
EOF
