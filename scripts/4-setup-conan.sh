#!/bin/bash -xue

python3.7 -m pip --no-cache-dir install wheel
python3.7 -m pip --no-cache-dir install conan meson

conan profile new --detect default
conan profile update "options.*:shared=True" default
conan profile update "settings.compiler.libcxx=libc++" default
