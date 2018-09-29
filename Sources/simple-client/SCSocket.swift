#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

extension fd_set {
    #if os(macOS)
    private static let __fd_set_count = Int(__DARWIN_FD_SETSIZE) / 32
    #elseif os(Linux)
    #if arch(arm)
    private static let __fd_set_count = 16
    #else
    private static let __fd_set_count = 32
    #endif
    #endif

    @inline(__always)
    private mutating func withCArray<T>(block: (UnsafeMutablePointer<Int32>) throws -> T) rethrows -> T {
        #if os(macOS)
        return try withUnsafeMutablePointer(to: &fds_bits) {
            try block(UnsafeMutableRawPointer($0).assumingMemoryBound(to: Int32.self))
        }
        #elseif os(Linux)
        return try withUnsafeMutablePointer(to: &__fds_bits) {
            try block(UnsafeMutableRawPointer($0).assumingMemoryBound(to: Int32.self))
        }
        #endif
    }

    /// Clears the set.
    ///
    /// - Remark: Replacement for the `FD_ZERO` macro.
    mutating func zero() {
        self.withCArray { $0.initialize(repeating: 0, count: fd_set.__fd_set_count) }
    }

    /// Add the given file descriptor to the set.
    ///
    /// - Remark: Replacement for the `FD_SET` macro.
    ///
    /// - Parameter fd: The file descriptor that should be added to the set.
    mutating func set(_ fd: Int32) {
        let intOffset = Int(fd) / 32
        let bitOffset = Int(fd) % 32
        let mask = Int32(bitPattern: UInt32(1 << bitOffset))
        self.withCArray { $0[intOffset] |= mask }
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
    private var socketfd: Int32

    /// Indicates whether there is some data that can be read fom the socket.
    var readable: Bool {
        // Specify how long the select can take to complete.
        var timeout = timeval(tv_sec: 0, tv_usec: 50000)

        // Create a read set with the socket.
        var readSet = fd_set()
        readSet.zero()
        readSet.set(self.socketfd)

        // Check whether the socket is not readable.
        if (select(self.socketfd + 1, &readSet, nil, nil, &timeout) <= 0) {
            return false
        }

        return true
    }

    // MARK: - Initializers

    /// Creates a new TCP socket.
    init() {
        self.socketfd = SCSocket.invalidSocket
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
            var retVal = SCSocket.socketError
            #if os(macOS)
            retVal = Darwin.close(self.socketfd)
            #elseif os(Linux)
            retVal = Glibc.close(self.socketfd)
            #endif

            // Check whether an error occurred while closing the socket.
            if retVal == SCSocket.socketError {
                print("ERROR: The socket could not be closed successfully!")
            }

            // Invalidate the socket.
            self.socketfd = SCSocket.invalidSocket
        }
    }

    /// Creates a connection to the given host via the given port.
    ///
    /// - Parameters:
    ///   - host: The host to connect to.
    ///   - port: The port that should be used for the connection.
    ///
    /// - Returns: `true` if the connection was successful; otherwise, `false`.
    func connect(toHost host: String, withPort port: UInt16) -> Bool {
        /// Close an existing connection.
        self.close()

        // Create a new socket.
        #if os(macOS)
        self.socketfd = socket(AF_INET, SOCK_STREAM, 0)
        #elseif os(Linux)
        self.socketfd = socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
        #endif

        // Check whether the newly created socket is invalid.
        if self.socketfd == SCSocket.invalidSocket {
            print("ERROR: The socket could not be created successfully!")
            return false
        }

        // Create the socket address.
        var socketAddress = sockaddr_in()
        socketAddress.sin_family = sa_family_t(AF_INET)
        socketAddress.sin_addr = in_addr(s_addr: inet_addr(host))
        socketAddress.sin_port = in_port_t((port << 8) + (port >> 8))

        // Connect to the host.
        let retVal = withUnsafePointer(to: &socketAddress) { socketAddressInPtr -> Int32 in
            let socketAddressPtr = UnsafeRawPointer(socketAddressInPtr).assumingMemoryBound(to: sockaddr.self)
            #if os(macOS)
            return Darwin.connect(self.socketfd, socketAddressPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            #elseif os(Linux)
            return Glibc.connect(self.socketfd, socketAddressPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            #endif
        }

        // Check whether an error occurred while connecting to the host.
        if retVal == SCSocket.socketError {
            print("ERROR: The connection to \(host) via port \(port) could not be established!")
            self.close()

            return false
        }

        return true
    }

    /// Read data from the socket. This method blocks if no data can be read
    /// from the socket.
    ///
    /// - Parameter data: The buffer to return the data in.
    func receive(into data: inout Data) {
        if self.socketfd != SCSocket.invalidSocket {
            // Loop until we have received the whole message.
            repeat {
                // Add the received part of the message to the internal buffer.
                let length = recv(self.socketfd, &self.readBuffer, SCSocket.bufferSize, 0)

                // Check whether the message is not empty.
                if length > 0 {
                    data.append(&self.readBuffer, count: length)
                } else {
                    break
                }
            } while self.readable
        }
    }

    /// Sends the given message to the host.
    ///
    /// - Parameter message: The message that should be sent to the host.
    func send(message: String) {
        if self.socketfd != SCSocket.invalidSocket && !message.isEmpty {
            message.withCString { bytes in
                // The length of the message.
                let length = message.count
                // The length of the message that is already sent to the host.
                var sentLength = 0

                // The return value of the low-level send function.
                var retVal = -1

                // Loop until we have sent the whole message to the host.
                while sentLength < length {
                    // Send the message to the host.
                    #if os(macOS)
                    retVal = Darwin.send(self.socketfd, bytes.advanced(by: sentLength), length - sentLength, 0)
                    #elseif os(Linux)
                    retVal = Glibc.send(self.socketfd, bytes.advanced(by: sentLength), length - sentLength, 0)
                    #endif

                    // Check whether an error occurred or nothing has been sent.
                    if (retVal <= 0) {
                        break
                    }

                    sentLength += retVal
                }
            }
        }
    }
}