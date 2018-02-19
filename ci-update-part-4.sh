#!/bin/bash -ue

echo 'EXECUTING PART 4'

mkdir -p $BOOST_ROOT
cd $BOOST_ROOT/../

curl -k -L --compressed 'https://dl.bintray.com/boostorg/release/1.66.0/source/boost_1_66_0.tar.bz2' > boost_1_66_0.tar.bz2
tar -xf boost_1_66_0.tar.bz2
rm boost_1_66_0.tar.bz2

cd boost_1_66_0
RT=$(pwd)
cd boost/asio/detail/
read -r -d '' PATCH <<- EOM || true
--- config.hpp	2018-02-11 13:41:39.000000000 +0100
+++ config.hpp.mine	2018-02-11 13:41:21.000000000 +0100
@@ -775,7 +775,11 @@
 #   if (__cplusplus >= 201402)
 #    if __has_include(<experimental/string_view>)
 #     define BOOST_ASIO_HAS_STD_STRING_VIEW 1
-#     define BOOST_ASIO_HAS_STD_EXPERIMENTAL_STRING_VIEW 1
+#     if __clang_major__ >= 7
+#      undef BOOST_ASIO_HAS_STD_EXPERIMENTAL_STRING_VIEW
+#     else
+#      define BOOST_ASIO_HAS_STD_EXPERIMENTAL_STRING_VIEW 1
+#     endif // __clang_major__ >= 7
 #    endif // __has_include(<experimental/string_view>)
 #   endif // (__cplusplus >= 201402)
 #  endif // defined(__clang__)
EOM
echo "$PATCH" | patch

cd $RT
../build.sh

cd ~

rm -rf $BOOST_ROOT/../boost_1_66_0
rm -rf /tmp/boost
