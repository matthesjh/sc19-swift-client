#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

extension fd_set {
    /// Clears the set.
    ///
    /// - Remark: Replacement for the `FD_ZERO` macro.
    mutating func zero() {
        self.fds_bits = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
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

        switch intOffset {
            case 0: self.fds_bits.0 |= mask
            case 1: self.fds_bits.1 |= mask
            case 2: self.fds_bits.2 |= mask
            case 3: self.fds_bits.3 |= mask
            case 4: self.fds_bits.4 |= mask
            case 5: self.fds_bits.5 |= mask
            case 6: self.fds_bits.6 |= mask
            case 7: self.fds_bits.7 |= mask
            case 8: self.fds_bits.8 |= mask
            case 9: self.fds_bits.9 |= mask
            case 10: self.fds_bits.10 |= mask
            case 11: self.fds_bits.11 |= mask
            case 12: self.fds_bits.12 |= mask
            case 13: self.fds_bits.13 |= mask
            case 14: self.fds_bits.14 |= mask
            case 15: self.fds_bits.15 |= mask
            case 16: self.fds_bits.16 |= mask
            case 17: self.fds_bits.17 |= mask
            case 18: self.fds_bits.18 |= mask
            case 19: self.fds_bits.19 |= mask
            case 20: self.fds_bits.20 |= mask
            case 21: self.fds_bits.21 |= mask
            case 22: self.fds_bits.22 |= mask
            case 23: self.fds_bits.23 |= mask
            case 24: self.fds_bits.24 |= mask
            case 25: self.fds_bits.25 |= mask
            case 26: self.fds_bits.26 |= mask
            case 27: self.fds_bits.27 |= mask
            case 28: self.fds_bits.28 |= mask
            case 29: self.fds_bits.29 |= mask
            case 30: self.fds_bits.30 |= mask
            case 31: self.fds_bits.31 |= mask
            default: break
        }
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
        self.socketfd = socket(AF_INET, SOCK_STREAM, 0)

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
        // Loop until we have received the whole message.
        repeat {
            // Add the received part of the message to the internal buffer.
            let length = recv(self.socketfd, &self.readBuffer[0], SCSocket.bufferSize, 0)

            // Check whether the message is not empty.
            if length > 0 {
                data.append(Data(bytes: self.readBuffer[0..<length]))
            } else {
                break
            }
        } while self.readable
    }

    /// Sends the given message to the host.
    ///
    /// - Parameter message: The message that should be sent to the host.
    func send(message: String) {
        if !message.isEmpty {
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