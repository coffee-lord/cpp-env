#!/bin/sh -ue

echo 'EXECUTING PART 4'

cd $BOOST_ROOT/../

curl -k -L --compressed 'https://dl.bintray.com/boostorg/release/1.65.0/source/boost_1_65_0.tar.bz2' > boost_1_65_0.tar.bz2
tar -xf boost_1_65_0.tar.bz2
rm boost_1_65_0.tar.bz2

cd boost_1_65_0
../build.sh

cd ~

rm -rf $BOOST_ROOT/../boost_1_65_0
rm -rf /tmp/boost
