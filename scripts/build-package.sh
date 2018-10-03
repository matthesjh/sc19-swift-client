#!/bin/sh

SWIFT_VERSION=4.2
PROJECT_DIR="${PWD}"

if [ "${TRAVIS_OS_NAME}" = "linux" ]; then
  echo "Downloading the Swift ${SWIFT_VERSION} toolchain..."
  cd ..
  wget https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu1404/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu14.04.tar.gz
  tar xzf swift-${SWIFT_VERSION}-RELEASE-ubuntu14.04.tar.gz
  export PATH="${PWD}/swift-${SWIFT_VERSION}-RELEASE-ubuntu14.04/usr/bin:${PATH}"
  cd "${PROJECT_DIR}"
fi

echo "Using Swift version:"
swift -version

echo "Building package..."
swift build