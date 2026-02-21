#!/bin/bash
set -e

OPENSSL_VERSION="3.3.0"
OPENSSL_URL="https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
PJSIP_VERSION="2.16"
PJSIP_URL="https://github.com/pjsip/pjproject/archive/refs/tags/${PJSIP_VERSION}.tar.gz"
NDK_PATH="$HOME/Android/Sdk/ndk/27.1.12297006"
APP_PLATFORM="android-24"
ABI="arm64-v8a"

export ANDROID_NDK_HOME=${NDK_PATH}
export PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"

# Build OpenSSL
wget ${OPENSSL_URL} -O openssl.tar.gz
tar -xzf openssl.tar.gz
rm openssl.tar.gz
cd openssl-${OPENSSL_VERSION}
./Configure android-aarch64 -fPIC no-asm shared --openssldir=openssl --prefix=$(pwd)/build
make -j$(nproc)
make install
cd ..
OPENSSL_DIR=$(pwd)/openssl-${OPENSSL_VERSION}/build

# Build PJSIP
wget ${PJSIP_URL} -O pjsip.tar.gz
tar -xzf pjsip.tar.gz
rm pjsip.tar.gz
cd pjproject-${PJSIP_VERSION}
export APP_PLATFORM=${APP_PLATFORM}
./configure-android --use-ndk-cflags --with-ssl=${OPENSSL_DIR} --disable-libyuv --disable-libwebrtc
make dep
make
cd pjsip/lib
cp *.a ../../libs/
cd ../../pjlib/lib
cp *.a ../../libs/
cd ../../pjlib-util/lib
cp *.a ../../libs/
cp *.a ../../libs/
cd ../../pjmedia/lib
cp *.a ../../libs/
cd ../../pjnath/lib
cp *.a ../../libs/
cd ../../..
rm -rf pjproject-${PJSIP_VERSION} openssl-${OPENSSL_VERSION}
echo "Built PJSIP ${PJSIP_VERSION} with OpenSSL ${OPENSSL_VERSION}"
