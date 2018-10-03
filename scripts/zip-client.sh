#!/bin/sh

EXECUTABLE_NAME=simple-client

echo "Using Swift version:"
swift -version

echo "Building package..."
swift build -c release -Xswiftc -O

echo "Zipping files..."
zip -j "${EXECUTABLE_NAME}".zip scripts/start-client.sh .build/release/"${EXECUTABLE_NAME}"