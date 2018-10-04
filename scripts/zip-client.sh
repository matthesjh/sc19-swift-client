#!/bin/sh

BUILD_CONFIG=release
EXECUTABLE_NAME=simple-client

echo "Using Swift version:"
swift -version

echo "Building package..."
swift build -c "${BUILD_CONFIG}" -Xswiftc -O

echo "Zipping files..."
zip -j "${EXECUTABLE_NAME}".zip scripts/start-client.sh .build/"${BUILD_CONFIG}"/"${EXECUTABLE_NAME}"