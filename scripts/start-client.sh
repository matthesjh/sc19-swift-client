#!/bin/sh

EXECUTABLE_NAME=simple-client

export LD_LIBRARY_PATH=/usr/lib/swift/linux:"${LD_LIBRARY_PATH}"

chmod u+x "${EXECUTABLE_NAME}"
./"${EXECUTABLE_NAME}" "$@"