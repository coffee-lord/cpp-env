apt-get update
apt-get install -y --no-install-recommends pkg-config git

python3 -m pip install --user --upgrade conan pip meson

CLANG_VERSION=$($LLVM_SDK_ROOT/stage/bin/clang -v 2>&1 | sed -n 's/.*clang version \(.\..\).*/\1/p')

export CONAN_USER_HOME=$(pwd)
conan remote add signal9 https://api.bintray.com/conan/signal9/conan > /dev/null 2>&1 || true

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

patch_pcs() {
	sed -i -e 's/\([^a-zA-Z]-\)I/\1isystem/g' -e 's/-L${libdir}/& -Wl,--rpath=${libdir}/g' **.pc
	export PKG_CONFIG_PATH=$(pwd)
}
