#!/bin/bash -xue

BUILD_DIR="/var/tmp/llvm"
SRC_DIR="/root/llvm"

download_src() {
	SRC_TAR=/tmp/src.tar.gz
	curl -L --compressed "https://github.com/llvm/llvm-project/archive/llvmorg-$1.tar.gz" > $SRC_TAR
	cd /root
	tar -xf $SRC_TAR
	rm $SRC_TAR
	mv llvm-project-llvmorg-$1 llvm
}

download_src 8.0.1

mkdir -p $BUILD_DIR

cd $BUILD_DIR

CFLAGS="\
-pipe \
-fomit-frame-pointer \
-fno-stack-protector \
-march=x86-64 -mtune=intel \
-fdata-sections -ffunction-sections \
-fPIC \
-O3"
CXXFLAGS="$CFLAGS"
LDFLAGS="\
-pipe \
-L/usr/local/lib \
-Wl,-rpath=/usr/local/lib \
-Wl,-rpath='\\\$ORIGIN' \
-fPIC \
-Wl,-s,--gc-sections,--as-needed,-z,norelro"

CMAKE_ARGS=$(cat <<EOF
LIBOMP_LIBFLAGS=-lm

# Enable Exception handling

LLVM_ENABLE_EH=OFF
LLVM_ENABLE_RTTI=OFF

# Default C++ stdlib to use ("libstdc++" or "libc++", empty for platform default
CLANG_DEFAULT_CXX_STDLIB=libc++

# Default runtime library to use ("libgcc" or "compiler-rt", empty for platform default)
CLANG_DEFAULT_RTLIB=compiler-rt

# Default linker to use (linker name or absolute path, empty for platform default)
CLANG_DEFAULT_LINKER="/usr/local/bin/ld.lld"

# Generate build targets for the Clang docs.
CLANG_INCLUDE_DOCS=OFF

# Generate build targets for the Clang unit tests.
CLANG_INCLUDE_TESTS=OFF

# Generate build targets for the Clang Extra Tools docs.
CLANG_TOOLS_EXTRA_INCLUDE_DOCS=OFF

# Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel.
CMAKE_BUILD_TYPE=Release

# Flags used by the compiler during all build types.
CMAKE_CXX_FLAGS="$CFLAGS"

# Flags used by the compiler during all build types.
CMAKE_C_FLAGS="$CFLAGS"

# Flags used by the linker.
CMAKE_EXE_LINKER_FLAGS="$LDFLAGS"

# Flags used by the linker during the creation of dll's.
CMAKE_SHARED_LINKER_FLAGS='$LDFLAGS'

# Generate and build compiler-rt unit tests.
COMPILER_RT_INCLUDE_TESTS=OFF

# Build the libc++ benchmarks and their dependancies
LIBCXX_INCLUDE_BENCHMARKS=OFF

# Build the libc++ documentation.
LIBCXX_INCLUDE_DOCS=OFF

# Build the libc++ tests.
LIBCXX_INCLUDE_TESTS=OFF

# Disables the Python scripting integration.
LLDB_DISABLE_PYTHON=ON

CMAKE_C_COMPILER_TARGET=x86_64-unknown-linux-gnu
# Build builtins only for the default target
COMPILER_RT_DEFAULT_TARGET_ONLY=ON

# Generate build targets for llvm documentation.
LLVM_INCLUDE_DOCS=OFF

# Generate build targets for the LLVM examples
LLVM_INCLUDE_EXAMPLES=OFF

# Include the Go bindings tests in test build targets.
LLVM_INCLUDE_GO_TESTS=OFF

# Generate build targets for the LLVM unit tests.
LLVM_INCLUDE_TESTS=OFF

# Whether to build bugpoint as part of LLVM
LLVM_TOOL_BUGPOINT_BUILD=OFF

# Whether to build bugpoint-passes as part of LLVM
LLVM_TOOL_BUGPOINT_PASSES_BUILD=OFF

# Whether to build llvm-go as part of LLVM
LLVM_TOOL_LLVM_GO_BUILD=OFF

LLVM_TARGETS_TO_BUILD=X86

LLVM_ENABLE_DOXYGEN=OFF
LLVM_ENABLE_SPHINX=OFF
LLVM_OPTIMIZED_TABLEGEN=ON

LLVM_ENABLE_PIC=ON

# Build OCaml bindings documentation.
LLVM_ENABLE_OCAMLDOC=OFF

LLVM_LINK_LLVM_DYLIB=ON

# Build and use the LLVM unwinder.
LIBCXXABI_USE_LLVM_UNWINDER=ON

CLANG_TOOL_ARCMT_TEST_BUILD=OFF
CLANG_TOOL_CLANG_DIFF_BUILD=OFF
CLANG_TOOL_CLANG_FORMAT_VS_BUILD=OFF
CLANG_TOOL_CLANG_FUZZER_BUILD=OFF
CLANG_TOOL_CLANG_IMPORT_TEST_BUILD=OFF
CLANG_TOOL_CLANG_OFFLOAD_BUNDLER_BUILD=OFF
CLANG_TOOL_C_ARCMT_TEST_BUILD=OFF
CLANG_TOOL_C_INDEX_TEST_BUILD=OFF
CLANG_TOOL_DIAGTOOL_BUILD=OFF
CLANG_TOOL_CLANG_REFACTOR_BUILD=OFF
CLANG_TOOL_CLANG_RENAME_BUILD=OFF
COMPILER_RT_BUILD_LIBFUZZER=OFF
LLVM_TOOL_LLVM_AS_FUZZER_BUILD=OFF
LLVM_TOOL_LLVM_C_TEST_BUILD=OFF
LLVM_TOOL_LLVM_ISEL_FUZZER_BUILD=OFF
LLVM_TOOL_LLVM_MC_ASSEMBLE_FUZZER_BUILD=OFF
LLVM_TOOL_LLVM_MC_DISASSEMBLE_FUZZER_BUILD=OFF
LLVM_TOOL_LLVM_OPT_FUZZER_BUILD=OFF
LLVM_TOOL_LLVM_SPECIAL_CASE_LIST_FUZZER_BUILD=OFF

LLVM_ENABLE_PROJECTS="clang;clang-tools-extra;libcxx;libcxxabi;libunwind;lldb;compiler-rt;lld;polly;openmp"
EOF
)

CMAKE_ARGS=$(echo -n "$CMAKE_ARGS" | sed -e '/^#/d' -e '/^$/d' -e 's/.*/-D&/' | tr '\n' ' ')

eval "cmake -G Ninja $CMAKE_ARGS $SRC_DIR/llvm"
ninja install

cd $SRC_DIR
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

export CC=/usr/local/bin/clang
export CXX=/usr/local/bin/clang++
export AR=/usr/local/bin/llvm-ar
export NM=/usr/local/bin/llvm-nm
export RANLIB=/usr/local/bin/llvm-ranlib

CMAKE_ARGS_STAGE_2=$(cat <<EOF

# Use libc++ if available.
LLVM_ENABLE_LIBCXX=ON

# Use lld as C and C++ linker.
LLVM_ENABLE_LLD=ON

# Use compiler-rt instead of libgcc
LIBCXX_USE_COMPILER_RT=ON

# Use compiler-rt instead of libgcc
LIBCXXABI_USE_COMPILER_RT=ON

# Use compiler-rt instead of libgcc
LIBUNWIND_USE_COMPILER_RT=ON

# Build LLVM with LTO. May be specified as Thin or Full to use a particular kind of LTO
LLVM_ENABLE_LTO=Thin

CMAKE_AR=$AR
CMAKE_RANLIB=$RANLIB
CMAKE_NM=$NM
EOF
)

CMAKE_ARGS_STAGE_2=$(echo -n "$CMAKE_ARGS_STAGE_2" | sed -e '/^#/d' -e '/^$/d' -e 's/.*/-D&/' | tr '\n' ' ')
CMAKE_ARGS="$CMAKE_ARGS $CMAKE_ARGS_STAGE_2"

eval "cmake -G Ninja $CMAKE_ARGS $SRC_DIR/llvm"
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

find /usr/local/lib -name '*.a' ! -name '*clang_rt*' ! -name 'libc++*' ! -name 'libunwind*' -delete
