#!/bin/sh

echo "Building package..."
swift build -c release -Xswiftc -O

echo "Zipping files..."
zip -j simple-client.zip scripts/start-client.sh .build/release/simple-client