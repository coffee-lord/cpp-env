#!/bin/sh -ue

echo 'EXECUTING PART 4'

cd $BOOST_ROOT/../

curl -k -L --compressed 'https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.bz2' > boost_1_64_0.tar.bz2
tar -xf boost_1_64_0.tar.bz2
rm boost_1_64_0.tar.bz2

cd boost_1_64_0
../build.sh

cd ~

rm -rf $BOOST_ROOT/../boost_1_64_0
rm -rf /tmp/boost
