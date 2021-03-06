#!/bin/bash -xue

python3 -m pip --no-cache-dir install wheel
python3 -m pip --no-cache-dir install conan meson gcovr

conan profile new --detect default
conan profile update "options.*:shared=True" default
conan profile update "settings.compiler.libcxx=libc++" default
