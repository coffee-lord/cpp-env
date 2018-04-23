EXE=$LLVM_SDK_ROOT/stage/bin/${0##*/}
ARGS=""
for ARG in "$@"; do
	ARGS="$ARGS \"$ARG\""
done

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

	strip_whitespace
	add_flags

	ARGS=$(echo -n "$ARGS" | sed 's/"-fmodules"/"--ccache-skip" &/g')
	ARGS=$(echo -n "$ARGS" | sed 's/" *" //g')
	# ARGS="$ARGS -Wno-narrowing"

	echo "${0##*/} $ARGS" >> /tmp/clang_log.txt
	eval exec $EXE $ARGS
}
