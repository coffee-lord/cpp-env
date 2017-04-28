#!/bin/sh -xue

UPDATE_GIT=1
IS_REBUILD=1

LLVM_ROOT=$(pwd)
export PATH="$LLVM_ROOT/stage/bin:/usr/bin:/bin"

BUILD_DIR="/tmp/llvm"

export CC=clang
export CXX=clang++

# export CC=gcc
# export CXX=g++

if ! [ "$LLVM_ROOT" = "/opt/llvm" ]; then
	echo 'Refusing to run outside of /opt/llvm'
	exit 0
fi

update_git() {
	TARGET_DIR="$LLVM_ROOT/$1"
	mkdir -p $TARGET_DIR
	TMP_DIR=$(mktemp -d)	
	cd $TMP_DIR
	curl -k -L --compressed $2 > src.zip
	unzip $TMP_DIR/src.zip
	SRC_DIR=$(find . -type d ! -name '.' | head -n 1)
	mv -T $SRC_DIR $TARGET_DIR
	rm -rf $TMP_DIR
	cd $LLVM_ROOT
}

if [ "$UPDATE_GIT" = "1" ]; then
	update_git src 'https://github.com/llvm-mirror/llvm/archive/master.zip'
	update_git src/tools/polly 'https://github.com/llvm-mirror/polly/archive/master.zip'
	update_git src/tools/clang 'https://github.com/llvm-mirror/clang/archive/master.zip'
	update_git src/tools/clang/tools/extra 'https://github.com/llvm-mirror/clang-tools-extra/archive/master.zip'
	update_git src/tools/lldb 'https://github.com/llvm-mirror/lldb/archive/master.zip'
	update_git src/tools/lld 'https://github.com/llvm-mirror/lld/archive/master.zip'
	update_git src/projects/libcxx 'https://github.com/llvm-mirror/libcxx/archive/master.zip'
	update_git src/projects/libcxxabi 'https://github.com/llvm-mirror/libcxxabi/archive/master.zip'
	update_git src/projects/compiler-rt 'https://github.com/llvm-mirror/compiler-rt/archive/master.zip'
	update_git src/projects/openmp 'https://github.com/llvm-mirror/openmp/archive/master.zip'
	update_git src/projects/libunwind 'https://github.com/llvm-mirror/libunwind/archive/master.zip'
fi

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR" stage

cd "$BUILD_DIR"

CFLAGS="\
-pipe \
-fomit-frame-pointer \
-fno-stack-protector \
-ffast-math \
-march=native -mtune=native \
-fdata-sections -ffunction-sections \
-fPIC \
-Ofast"
LDFLAGS="
-pipe \
-fPIC \
-Wl,--gc-sections,--as-needed,-z,norelro \
-L$LLVM_ROOT/stage/lib \
-Wl,-rpath=$LLVM_ROOT/stage/lib \
-Wl,-rpath='\\\$ORIGIN' \
"

if [ "$IS_REBUILD" = 1 ]; then
	LDFLAGS="\
-lunwind \
-lm \
-Wl,--threads \
$LDFLAGS"
fi

cat >/tmp/file.txt <<EOF

# Default C++ stdlib to use ("libstdc++" or "libc++", empty for platform default
CLANG_DEFAULT_CXX_STDLIB=libc++

# Default runtime library to use ("libgcc" or "compiler-rt", empty for platform default)
CLANG_DEFAULT_RTLIB=compiler-rt

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

# Install path prefix, prepended onto install directories.
CMAKE_INSTALL_PREFIX="$LLVM_ROOT/stage"

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

EOF

CMAKE_ARGS=$(cat /tmp/file.txt | sed '/^#/d' | sed '/^$/d' | sed 's/.*/-D&/' | tr '\n' ' ')

cat >/tmp/file.txt <<EOF

# Use libc++ if available.
LLVM_ENABLE_LIBCXX=ON

# Use lld as C and C++ linker.
LLVM_ENABLE_LLD=ON

# Use compiler-rt instead of libgcc
LIBCXX_USE_COMPILER_RT=ON

# Use compiler-rt instead of libgcc
LIBCXXABI_USE_COMPILER_RT=ON

# Build and use the LLVM unwinder.
LIBCXXABI_USE_LLVM_UNWINDER=ON

# Build LLVM with LTO. May be specified as Thin or Full to use a particular kind of LTO
# LLVM_ENABLE_LTO=Full

EOF

CMAKE_ARGS_STAGE_2=$(cat /tmp/file.txt | sed '/^#/d' | sed '/^$/d' | sed 's/.*/-D&/' | tr '\n' ' ')

rm /tmp/file.txt

if [ "$IS_REBUILD" = 1 ]; then
	CMAKE_ARGS="$CMAKE_ARGS $CMAKE_ARGS_STAGE_2"
fi

eval "cmake -G Ninja $CMAKE_ARGS $LLVM_ROOT/src"
