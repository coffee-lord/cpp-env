EXE=$LLVM_SDK_ROOT/stage/bin/${0##*/}
ARGS="$*"

COMMON_CFLAGS="\
-pipe \
-Qunused-arguments \
-fPIC \
-fdata-sections -ffunction-sections \
-stdlib=libc++ \
-march=native -mtune=native"

COMMON_LDFLAGS="\
-pipe \
-fPIC \
-L$LLVM_SDK_ROOT/stage/lib \
-Wl,-rpath=$LLVM_SDK_ROOT/stage/lib \
-Wl,-rpath='\$ORIGIN' \
-rtlib=compiler-rt \
-stdlib=libc++ \
-ldl \
-lc++ \
-lc++abi \
-lunwind \
-Wl,--threads,--gc-sections,--as-needed,-z,norelro"

strip() {
	ARGS=$(echo -n "$ARGS" | sed -r "s/(^| +)$*(\$| +)/ /g")
}

strip_any() {
	ARGS=$(echo -n "$ARGS" | sed -r "s/$*/ /g")
}

strip_tail() {
	ARGS=$(echo -n "$ARGS" | sed -r "s/(^| +)$*[^ ]*/ /g")
}

check_args() {
	echo "$ARGS" | grep -qE -- "(^| +)$1(\$| +)"
}

add_cc() {
	ARGS="$ARGS $COMMON_CFLAGS $CFLAGS"
}

add_flags() {
	if check_args '-c'; then
		add_cc
		return 0
	fi
	if check_args '-E'; then
		add_cc
		return 0
	fi
	if check_args '-x c\+\+-header'; then
		add_cc
		return 0
	fi
	ARGS="$ARGS $COMMON_LDFLAGS $LDFLAGS"
}

strip_whitespace() {
	ARGS=$(echo -n "$ARGS" | sed "s/^ *\(.*\) *$/\1/g")
	ARGS=$(echo -n "$ARGS" | sed "s/ \+/ /g")
}

run_exe() {
	strip_any '-fPIC'
	strip_any '-fPIE'
	strip_any '-Wall'
	strip_any '-fdata-sections'
	strip_any '-ffunction-sections'
	strip '-Wl,--gc-sections'
	strip '-Wl,--enable-new-dtags'
	strip '-fvisibility=hidden'
	strip_any '-fvisibility=hidden'
	strip '-fvisibility hidden'
	strip '-fvisibility-inlines-hidden'
	strip '-ccc-gcc-name g++'
	strip '-fstack-protector'
	strip '-fno-omit-frame-pointer'
	strip_tail '-flto'
	strip_tail '-g'
	strip_tail '-march'
	strip_tail '-mtune'
	strip_tail '-O'
	strip_tail '-stdlib'
	strip_tail '-rtlib'
	ARGS=$(echo -n "$ARGS" | sed "s/-std=gnu++14/-std=c++1z/g")

	strip_whitespace
	add_flags

	echo "${0##*/}" $ARGS >> /tmp/clang_log.txt
	exec $EXE $ARGS
}
