#!/bin/bash
set -e

PJSIP_VERSION="2.16"
PJSIP_URL="https://github.com/pjsip/pjproject/archive/refs/tags/${PJSIP_VERSION}.tar.gz"
PJSIP_DIR="pjproject-${PJSIP_VERSION}"
LOCK=".libs.lock"
NDK_PATH="$HOME/Android/Sdk/ndk/27.1.12297006"  # your NDK from earlier

if ! type "tar" > /dev/null; then
    echo "Missed tar dependency" >&2;
    exit 1;
fi

if [ -f ${LOCK} ]; then
    CURRENT_VERSION=$(cat ${LOCK})
    if [ "${CURRENT_VERSION}" == "${PJSIP_VERSION}" ]; then
        echo "PJSIP ${PJSIP_VERSION} already built"
        exit 0
    fi
fi

# Download and extract source
wget ${PJSIP_URL} -O pjsip.tar.gz
tar -xzf pjsip.tar.gz
rm pjsip.tar.gz
cd ${PJSIP_DIR}

# Configure for Android
export ANDROID_NDK_ROOT=${NDK_PATH}
./configure-android --use-ndk-cflags --min-api=24 --openssl-version=3.3 --disable-libyuv --disable-libwebrtc --disable-video

# Build
make dep
make

# Copy libs to jni/libs
cp pjsip/lib/*.a ../libs/
cp pjlib/lib/*.a ../libs/
cp pjlib-util/lib/*.a ../libs/
cp pjmedia/lib/*.a ../libs/
cp pjnath/lib/*.a ../libs/
cp pjlib/bin/*.a ../libs/  # if any

cd ..
rm -rf ${PJSIP_DIR}
echo "${PJSIP_VERSION}" > ${LOCK}

echo "PJSIP ${PJSIP_VERSION} built and libs copied"
