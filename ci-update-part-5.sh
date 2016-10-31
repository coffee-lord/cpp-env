#!/bin/sh -ue

echo 'EXECUTING PART 5'

cd ~
python3 -m pip install --user --upgrade conan pip

mkdir -p ~/.conan

CLANG_VERSION=$($LLVM_SDK_ROOT/stage/bin/clang -v 2>&1 | sed -n 's/.*clang version \(.\..\).*/\1/p')

cat > ~/.conan/conan.conf <<EOF
[storage]
path: ~/.conan/data

[settings_defaults]
arch=x86_64
build_type=Release
compiler=clang
compiler.libcxx=libc++
compiler.version=$CLANG_VERSION
os=Linux
EOF

cat > ~/.conan/settings.yml <<EOF
os: [Windows, Linux, Macos, Android, iOS, FreeBSD]
arch: [x86, x86_64, ppc64le, ppc64, armv6, armv7, armv7hf, armv8]
compiler:
    gcc:
        version: ["4.4", "4.5", "4.6", "4.7", "4.8", "4.9", "5.1", "5.2", "5.3", "5.4", "6.1", "6.2"]
        libcxx: [libstdc++, libstdc++11]
        threads: [None, posix, win32] #  Windows MinGW
        exception: [None, dwarf2, sjlj, seh] # Windows MinGW
    Visual Studio:
        runtime: [MD, MT, MTd, MDd]
        version: ["8", "9", "10", "11", "12", "14"]
    clang:
        version: ["3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9", "$CLANG_VERSION"]
        libcxx: [libstdc++, libstdc++11, libc++]
    apple-clang:
        version: ["5.0", "5.1", "6.0", "6.1", "7.0", "7.3", "8.0"]
        libcxx: [libstdc++, libc++]

build_type: [None, Debug, Release]
EOF

apt-get -y clean
