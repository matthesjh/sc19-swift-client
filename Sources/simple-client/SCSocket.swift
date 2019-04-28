#if os(macOS)
import Darwin

let __FD_SETSIZE = __DARWIN_FD_SETSIZE
let _close = Darwin.close
let _connect = Darwin.connect
let _send = Darwin.send
#elseif os(Linux)
import Glibc

let _close = Glibc.close
let _connect = Glibc.connect
let _send = Glibc.send
#else
#error("Unsupported platform!")
#endif

import Foundation

extension fd_set {
    // MARK: - Properties

    /// The maximum number of file descriptors in `fd_set`.
    private static let setSize = Int(__FD_SETSIZE) / 32

    // MARK: - Methods

    /// Calls the given closure with a mutable pointer to the underlying set.
    ///
    /// - Parameter body: A closure that takes a mutable pointer to the
    ///   underlying set as its sole argument. If the closure has a return
    ///   value, that value is also used as the return value of the
    ///   `withCArray(_:)` function. The pointer argument is valid only for the
    ///   duration of the function's execution.
    @inline(__always)
    private mutating func withCArray<T>(_ body: (UnsafeMutablePointer<Int32>) throws -> T) rethrows -> T {
        #if os(macOS)
        return try withUnsafeMutablePointer(to: &fds_bits) {
            try body(UnsafeMutableRawPointer($0).assumingMemoryBound(to: Int32.self))
        }
        #elseif os(Linux)
        return try withUnsafeMutablePointer(to: &__fds_bits) {
            try body(UnsafeMutableRawPointer($0).assumingMemoryBound(to: Int32.self))
        }
        #endif
    }

    /// Clears the set.
    ///
    /// - Remark: Replacement for the `FD_ZERO` macro.
    mutating func zero() {
        self.withCArray { $0.initialize(repeating: 0, count: fd_set.setSize) }
    }

    /// Adds the given file descriptor to the set.
    ///
    /// - Remark: Replacement for the `FD_SET` macro.
    ///
    /// - Parameter fd: The file descriptor to be added to the set.
    mutating func set(_ fd: Int32) {
        let intOffset = Int(fd) / 32
        let bitOffset = Int(fd) % 32
        self.withCArray { $0[intOffset] |= Int32(bitPattern: 1 << bitOffset) }
    }
}

/// A low-level BSD sockets wrapper for TCP connections.
class SCSocket {
    // MARK: - Properties

    /// The size of the read buffer.
    private static let bufferSize = 4096
    /// The value of an invalid socket.
    private static let invalidSocket: Int32 = -1
    /// The error value of the low-level BSD socket operations.
    private static let socketError: Int32 = -1

    /// The buffer to store the data received from the host.
    private var readBuffer: [UInt8]
    /// The low-level BSD socket used for the TCP connection.
    private var socketfd = invalidSocket

    /// Indicates whether there is some data that can be read from the TCP
    /// socket.
    var readable: Bool {
        // Specify how long the select can take to complete.
        var timeout = timeval(tv_sec: 0, tv_usec: 1000)

        // Create a read set with the socket.
        var readSet = fd_set()
        readSet.zero()
        readSet.set(self.socketfd)

        // Check whether the socket is readable.
        return select(self.socketfd + 1, &readSet, nil, nil, &timeout) > 0
    }

    // MARK: - Initializers

    /// Creates a new TCP socket.
    init() {
        self.readBuffer = Array(repeating: 0, count: SCSocket.bufferSize)
    }

    // MARK: - Deinitializers

    /// Destroys the TCP socket.
    deinit {
        self.close()
    }

    // MARK: - Methods

    /// Closes the connection to the host.
    func close() {
        // Check whether the socket is valid.
        if self.socketfd != SCSocket.invalidSocket {
            // Check whether an error occurred while closing the socket.
            if _close(self.socketfd) == SCSocket.socketError {
                print("ERROR: The socket could not be closed successfully!")
            }

            // Invalidate the socket.
            self.socketfd = SCSocket.invalidSocket
        }
    }

    /// Creates a connection to the given host via the given port.
    ///
    /// Closes an already existing connection before creating a new one.
    ///
    /// - Parameters:
    ///   - host: The host to connect to.
    ///   - port: The port to be used for the connection.
    ///
    /// - Returns: `true` if the connection was successful; otherwise, `false`.
    func connect(toHost host: String, withPort port: UInt16) -> Bool {
        // Close an existing connection.
        self.close()

        // Specify the criteria for the socket address selection.
        var hints = addrinfo()
        hints.ai_family = AF_INET
        #if os(macOS)
        hints.ai_socktype = SOCK_STREAM
        #elseif os(Linux)
        hints.ai_socktype = Int32(SOCK_STREAM.rawValue)
        #endif
        hints.ai_protocol = 0

        // Resolve the host to an IPv4 address.
        var addrInfoPtr: UnsafeMutablePointer<addrinfo>!
        guard getaddrinfo(host, "\(port)", &hints, &addrInfoPtr) == 0 else {
            print("ERROR: The host could not be resolved!")

            return false
        }

        let addrInfo = addrInfoPtr.pointee

        // Create a new socket.
        self.socketfd = socket(addrInfo.ai_family, addrInfo.ai_socktype, addrInfo.ai_protocol)

        // Check whether the newly created socket is valid.
        guard self.socketfd != SCSocket.invalidSocket else {
            print("ERROR: The socket could not be created successfully!")

            return false
        }

        // Connect to the host and check whether an error occurred.
        guard _connect(self.socketfd, addrInfo.ai_addr, addrInfo.ai_addrlen) != SCSocket.socketError else {
            print("ERROR: The connection to \(host) via port \(port) could not be established!")
            self.close()

            return false
        }

        return true
    }

    /// Reads data from the TCP socket.
    ///
    /// This method blocks if no data can be read from the TCP socket.
    ///
    /// - Parameter data: The buffer to return the data in.
    func receive(into data: inout Data) {
        // Loop until we have received the whole message.
        repeat {
            // Add the received part of the message to the internal buffer.
            let length = recv(self.socketfd, &self.readBuffer, SCSocket.bufferSize, 0)

            // Check whether the message is not empty.
            guard length > 0 else {
                break
            }

            // Add the received part of the message to the callers buffer.
            data.append(&self.readBuffer, count: length)
        } while self.readable
    }

    /// Sends the given message to the host.
    ///
    /// - Parameter message: The message to be sent to the host.
    func send(message: String) {
        message.withCString {
            // The length of the message.
            let length = message.count
            // The length of the message that is already sent to the host.
            var sentLength = 0

            // Loop until we have sent the whole message to the host.
            while sentLength < length {
                // Send the (remaining) message to the host.
                let retVal = _send(self.socketfd, $0.advanced(by: sentLength), length - sentLength, 0)

                // Check whether an error occurred or nothing has been sent.
                guard retVal > 0 else {
                    break
                }

                sentLength += retVal
            }
        }
    }
}