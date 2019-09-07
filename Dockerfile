FROM debian:sid-slim

WORKDIR /root

COPY scripts/1-install-base.sh scripts/
RUN scripts/1-install-base.sh

COPY scripts/2-build-clang.sh scripts/
RUN scripts/2-build-clang.sh

ENV CONAN_USER_HOME=/root \
	CC=clang \
	CXX=clang++ \
	AR=llvm-ar \
	NM=llvm-nm \
	RANLIB=llvm-ranlib

COPY scripts/3-cleanup.sh scripts/
RUN scripts/3-cleanup.sh

COPY scripts/4-setup-conan.sh scripts/
RUN scripts/4-setup-conan.sh
