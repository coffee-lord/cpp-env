#!/bin/sh -ue

echo 'EXECUTING PART 5'

cd ~
python3 -m pip install --user --upgrade conan pip

mkdir -p ~/.conan

CLANG_VERSION=$($LLVM_SDK_ROOT/stage/bin/clang -v 2>&1 | sed -n 's/.*clang version \(.\..\).*/\1/p')

cat > ~/.conan/conan.conf <<EOF
[settings_defaults]
arch=x86_64
build_type=Release
compiler=clang
compiler.libcxx=libc++
compiler.version=$CLANG_VERSION
os=Linux
EOF

cat > ~/.conan/settings.yml <<EOF
os: [Linux]
arch: [x86_64]
compiler:
    clang:
        version: ["$CLANG_VERSION"]
        libcxx: [libc++]
build_type: [Release]
EOF

apt-get -y clean
