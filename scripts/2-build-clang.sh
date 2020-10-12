#!/bin/bash -xue

BUILD_DIR="/var/tmp/llvm"
SRC_DIR="/root/llvm"
LLVM_VERSION="11.0.0"
LLVM_ROOT="/usr/local"

SRC_TAR=/tmp/src.tar.gz
curl -L --compressed "https://github.com/llvm/llvm-project/archive/llvmorg-$LLVM_VERSION.tar.gz" > $SRC_TAR
tar -xf $SRC_TAR
rm $SRC_TAR
mv llvm-project-llvmorg-$LLVM_VERSION $SRC_DIR

mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"

export CXX="g++"
export CC="gcc"
export CFLAGS="\
-pipe \
-fomit-frame-pointer \
-fno-stack-protector \
-march=x86-64 -mtune=intel \
-fdata-sections -ffunction-sections"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="\
-pipe \
-Wl,-s,--gc-sections,--as-needed,-z,norelro \
-L$LLVM_ROOT/lib \
-Wl,-rpath=$LLVM_ROOT/lib \
-Wl,-rpath='\$ORIGIN'"

CMAKE_ARGS=$(cat <<EOF
LLVM_BUILD_LLVM_DYLIB=ON
LLVM_LINK_LLVM_DYLIB=ON
LLVM_TARGETS_TO_BUILD=X86
LLVM_INSTALL_TOOLCHAIN_ONLY=ON
LLVM_INCLUDE_DOCS=OFF
LLVM_INCLUDE_EXAMPLES=OFF
LLVM_INCLUDE_GO_TESTS=OFF
LLVM_ENABLE_EH=OFF
LLVM_ENABLE_RTTI=OFF

CMAKE_BUILD_TYPE=MinSizeRel
CMAKE_INSTALL_PREFIX="$LLVM_ROOT"

CLANG_DEFAULT_RTLIB=compiler-rt
CLANG_DEFAULT_CXX_STDLIB=libc++
CLANG_DEFAULT_LINKER=lld
CLANG_DEFAULT_OBJCOPY=llvm-objcopy
CLANG_ENABLE_ARCMT=OFF
CLANG_ENABLE_STATIC_ANALYZER=ON

LIBCXX_ABI_UNSTABLE=ON
LIBCXX_CXX_ABI_INCLUDE_PATHS=$SRC_DIR/libcxxabi/include
LIBCXX_CXX_ABI=libcxxabi
LIBCXXABI_USE_LLVM_UNWINDER=ON

COMPILER_RT_BUILD_LIBFUZZER=OFF
CMAKE_C_COMPILER_TARGET=x86_64-unknown-linux-gnu
COMPILER_RT_DEFAULT_TARGET_ONLY=ON

BENCHMARK_ENABLE_ASSEMBLY_TESTS=OFF
CLANG_INCLUDE_TESTS=OFF
CLANG_TOOL_ARCMT_TEST_BUILD=OFF
CLANG_TOOL_CLANG_IMPORT_TEST_BUILD=OFF
CLANG_TOOL_C_ARCMT_TEST_BUILD=OFF
CLANG_TOOL_C_INDEX_TEST_BUILD=OFF
COMPILER_RT_INCLUDE_TESTS=OFF
LIBCXXABI_INCLUDE_TESTS=OFF
LIBCXX_INCLUDE_TESTS=OFF
LLDB_INCLUDE_TESTS=OFF
LLVM_INCLUDE_TESTS=OFF
LLVM_TOOL_LLVM_C_TEST_BUILD=OFF
EOF
)

CMAKE_ARGS=$(echo -n "$CMAKE_ARGS" | sed -e '/^#/d' -e '/^$/d' -e 's/.*/-D&/' | tr '\n' ' ')

eval "cmake -G Ninja \
 -DLIBCXXABI_LIBCXX_PATH=$SRC_DIR/libcxx \
 -DCMAKE_INSTALL_PREFIX="$LLVM_ROOT" \
 -DCMAKE_BUILD_TYPE=MinSizeRel \
 $SRC_DIR/libcxxabi"

ninja install

cd ..
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

eval "cmake -G Ninja \
 -DLLVM_ENABLE_PROJECTS='clang;libcxx;libcxxabi;libunwind;compiler-rt;lld' \
 $CMAKE_ARGS \
 $SRC_DIR/llvm"

ninja install

cd ..
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

export CFLAGS="$CFLAGS -Oz"
export CXXFLAGS="$CXXFLAGS -Oz"
export LDFLAGS="$LDFLAGS -lm -Oz"
export CXX="$LLVM_ROOT/bin/clang++"
export CC="$LLVM_ROOT/bin/clang"

eval "cmake -G Ninja \
 -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;libcxx;libcxxabi;libunwind;lldb;compiler-rt;lld;polly;openmp' \
 -DLIBUNWIND_USE_COMPILER_RT=ON \
 -DLIBCXXABI_USE_COMPILER_RT=ON \
 -DLIBCXX_USE_COMPILER_RT=ON \
 -DOPENMP_ENABLE_LIBOMPTARGET=OFF \
 -DLLVM_ENABLE_LIBCXX=ON \
 -DLLVM_ENABLE_LLD=ON \
 $CMAKE_ARGS \
 $SRC_DIR/llvm"

ninja install

cd ~
rm -rf $BUILD_DIR $SRC_DIR

ln -sf /usr/local/bin/ld.lld /usr/bin/ld

mkdir -p /opt/bin
cd /opt/bin

make_clang_exe() {
	cat > $1 <<EOF
#!/bin/bash

ARGS="-L/usr/local/lib -Wl,-rpath=/usr/local/lib"
for i do [[ \$i == "-c" || \$i == "-E" ]] && ARGS= && break ; done
exec /usr/local/bin/$1 \$ARGS \$*
EOF
	chmod +x $1
}

make_clang_exe clang
make_clang_exe clang++
