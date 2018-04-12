EXE=$LLVM_SDK_ROOT/stage/bin/${0##*/}
ARGS="$*"

COMMON_CFLAGS="\
-pipe \
-Qunused-arguments \
-fPIC \
-fdata-sections -ffunction-sections \
-stdlib=libc++"

COMMON_LDFLAGS="\
-L$LLVM_SDK_ROOT/stage/lib \
-Wl,-rpath=$LLVM_SDK_ROOT/stage/lib \
-Wl,-rpath='\$ORIGIN' \
-rtlib=compiler-rt \
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

add_flags() {
	ARGS="$ARGS $COMMON_CFLAGS $CFLAGS"
	check_args '-c' && return 0
	check_args '-E' && return 0
	check_args '-x c\+\+-header' && return 0
	ARGS="$ARGS $COMMON_LDFLAGS $LDFLAGS"
}

strip_whitespace() {
	ARGS=$(echo -n "$ARGS" | sed "s/^ *\(.*\) *$/\1/g")
	ARGS=$(echo -n "$ARGS" | sed "s/ \+/ /g")
}

run_exe() {
	# strip_any '-fPIC'
	strip_any '-fPIE'
	strip_any '-Wall'
	# strip_any '-fdata-sections'
	# strip_any '-ffunction-sections'
	# strip '-Wl,--gc-sections'
	strip '-Wl,--enable-new-dtags'
	strip '-Wl,--as-needed'
	# strip '-fvisibility=hidden'
	# strip_any '-fvisibility=hidden'
	# strip '-fvisibility hidden'
	# strip '-fvisibility-inlines-hidden'
	strip '-ccc-gcc-name g++'
	strip '-fstack-protector'
	strip '-fno-omit-frame-pointer'
	#strip_tail '-flto'
	strip_tail '-g'
	strip_tail '-march'
	strip_tail '-mtune'
	strip_tail '-O'
	strip_tail '-Wl,-O'
	strip_tail '-stdlib'
	strip_tail '-rtlib'

	if ! echo "$0" | grep -q -- "-std="; then
		if echo "$0" | grep -q -- "++"; then
			ARGS="$ARGS -Wno-narrowing"
		fi
	fi

	strip_whitespace
	add_flags

	ARGS=$(echo -n "$ARGS" | sed "s/-flto /-flto=thin /g")
	ARGS=$(echo -n "$ARGS" | sed "s/-std=c++17 /-std=c++2a /g")
	ARGS=$(echo -n "$ARGS" | sed "s/-std=c++14 /-std=c++2a /g")
	ARGS=$(echo -n "$ARGS" | sed "s/-fprofile-generate /-fprofile-generate=\/tmp\/clang_pgo /g")
	ARGS=$(echo -n "$ARGS" | sed "s/-fprofile-use /-fprofile-use=\/tmp\/clang_pgo /g")

	echo "${0##*/} $ARGS" >> /tmp/clang_log.txt
	eval exec $EXE $ARGS
}
