FROM debian:sid-slim

ENV LLVM_SDK_ROOT=/opt/llvm BOOST_ROOT=/opt/llvm-boost/stage CONAN_CMAKE_GENERATOR=Ninja

ADD ci-update-part-1.sh /root
RUN /root/ci-update-part-1.sh && rm /root/ci-update-part-1.sh

ADD opt /opt

ADD ci-update-part-2.sh /root
RUN /root/ci-update-part-2.sh && rm /root/ci-update-part-2.sh
ADD ci-update-part-3.sh /root
RUN /root/ci-update-part-3.sh && rm /root/ci-update-part-3.sh
ADD ci-update-part-4.sh /root
RUN /root/ci-update-part-4.sh && rm /root/ci-update-part-4.sh
ADD ci-update-part-5.sh /root
RUN /root/ci-update-part-5.sh && rm /root/ci-update-part-5.sh

ENV PATH=/opt/llvm/bin-release:/opt/llvm/stage/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin:/bin CC=clang CXX=clang++
