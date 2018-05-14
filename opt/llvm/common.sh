EXE=$LLVM_SDK_ROOT/stage/bin/${0##*/}
ARGS=""
for ARG in "$@"; do
	ARG=${ARG//\"/\\\"}
	ARGS="$ARGS \"$ARG\""
done

escape() {
	for a in $1; do
		echo -n \""$a"\"' '
	done
}

COMMON_CFLAGS="\
-pipe \
-Qunused-arguments \
-fPIC \
-fdata-sections -ffunction-sections \
-stdlib=libc++"
COMMON_CFLAGS=$(escape "$COMMON_CFLAGS")

COMMON_LDFLAGS="\
-L$LLVM_SDK_ROOT/stage/lib \
-Wl,-rpath=$LLVM_SDK_ROOT/stage/lib \
-Wl,-rpath='\\\$ORIGIN' \
-rtlib=compiler-rt \
-ldl \
-lc++ \
-lc++abi \
-lunwind \
-Wl,--threads,--gc-sections,--as-needed,-z,norelro"
COMMON_LDFLAGS=$(escape "$COMMON_LDFLAGS")

strip() {
	ARGS=$(echo -n "$ARGS" | sed -r "s/(^|\")$*(\$|\")/ /g")
}

strip_any() {
	ARGS=$(echo -n "$ARGS" | sed -r "s/$*/ /g")
}

strip_tail() {
	ARGS=$(echo -n "$ARGS" | sed -r "s/(^|\")$*[^\"]*/\"/g")
}

check_args() {
	echo "$ARGS" | grep -qE -- "(^|\")$1(\$|\")"
}

add_flags() {
	CFLAGS=$(escape "$CFLAGS")
	ARGS="$ARGS $COMMON_CFLAGS $CFLAGS"
	check_args '-c' && return 0
	check_args '-E' && return 0
	check_args '-x c\+\+-header' && return 0
	LDFLAGS=$(escape "$LDFLAGS")
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
	# strip '-Wl,--no-undefined'
	strip '-Wl,--enable-new-dtags'
	strip '-Wl,--as-needed'
	# strip '-fvisibility=hidden'
	# strip_any '-fvisibility=hidden'
	# strip '-fvisibility hidden'
	# strip '-fvisibility-inlines-hidden'
	strip '-ccc-gcc-name g++'
	strip '-fstack-protector'
	strip '-fno-omit-frame-pointer'
	strip_tail '-flto'
	strip_tail '-g'
	strip_tail '-march'
	strip_tail '-mtune'
	strip_tail '-O'
	strip_tail '-Wl,-O'
	strip_tail '-stdlib'
	strip_tail '-rtlib'

	ARGS=$(echo -n "$ARGS" | sed 's/ "[^" ]*$ORIGIN[^" ]*" / /g')

	ARGS=$(echo -n "$ARGS" | sed 's/" " *" "/" "/g')

	strip_whitespace
	add_flags

	echo "${0##*/} $ARGS" >> /tmp/clang.log
	eval exec $EXE $ARGS
}
