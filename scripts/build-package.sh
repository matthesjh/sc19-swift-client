#!/bin/sh

SWIFT_VERSION=4.2.3

if [ "${TRAVIS_OS_NAME}" = "linux" ]; then
  echo "Downloading the Swift ${SWIFT_VERSION} toolchain..."
  wget https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu1604/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu16.04.tar.gz
  tar xzf swift-${SWIFT_VERSION}-RELEASE-ubuntu16.04.tar.gz
  export PATH="${TRAVIS_BUILD_DIR}"/swift-${SWIFT_VERSION}-RELEASE-ubuntu16.04/usr/bin:"${PATH}"
fi

echo "Using Swift version:"
swift -version

echo "Building package..."
swift build