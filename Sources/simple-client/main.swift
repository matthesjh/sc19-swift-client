#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#else
#error("Unsupported platform!")
#endif

/// The name of the executable.
let executableName = "simple-client"
/// The version number of the executable.
let versionNumber = "1.2.0"

/// The default IP address of the host to connect to.
let defaultHost = "127.0.0.1"
/// The default port used for the connection.
let defaultPort: UInt16 = 13050

/// The IP address of the host to connect to.
var host = defaultHost
/// The port used for the connection.
var port = defaultPort
/// The reservation code to join a prepared game.
var reservation = ""
/// The strategy used for the game.
var strategy = ""

/// Prints the help message into the standard output.
func printHelpMessage() {
    print("""
        Usage: \(executableName) [options]
          -h, --host:
              The IP address of the host to connect to (default: \(defaultHost)).
          -p, --port:
              The port used for the connection (default: \(defaultPort)).
          -r, --reservation:
              The reservation code to join a prepared game.
          -s, --strategy:
              The strategy used for the game.
          --help:
              Print this help message.
          --version:
              Print the version number.
        """)
}

/// Exits the program with the given error message.
///
/// - Parameter error: The error message to print into the standard output.
func exit(withError error: String) -> Never {
    if !error.isEmpty {
        print("ERROR: \(error)")
    }

    printHelpMessage()
    exit(EXIT_FAILURE)
}

/// The command-line arguments.
let argv = CommandLine.arguments
/// The number of command-line arguments.
let argc = argv.count

// Parse the command-line arguments.
var i = 1
while i < argc {
    switch argv[i] {
        case "--help":
            printHelpMessage()
            exit(EXIT_SUCCESS)
        case "--version":
            print("\(executableName) version \(versionNumber)")
            exit(EXIT_SUCCESS)
        case let arg where arg.hasPrefix("-"):
            i += 1

            guard i < argc else {
                exit(withError: "Missing value for the option \"\(arg)\"!")
            }

            let argValue = argv[i]

            switch arg {
                case "-h", "--host":
                    host = argValue
                case "-p", "--port":
                    guard let portValue = UInt16(argValue) else {
                        exit(withError: "The value \"\(argValue)\" can not be converted to a port number!")
                    }
                    port = portValue
                case "-r", "--reservation":
                    reservation = argValue
                case "-s", "--strategy":
                    strategy = argValue
                default:
                    exit(withError: "Unrecognized option \"\(arg)\"!")
            }
        case let arg:
            exit(withError: "Unrecognized argument \"\(arg)\"!")
    }

    i += 1
}

if host.isEmpty || host == "localhost" {
    host = defaultHost
}

// Create a TCP socket.
let tcpSocket = SCSocket()

// Connect to the game server.
if tcpSocket.connect(toHost: host, withPort: port) {
    print("Connected to the game server!")

    // Handle the game and the communication with the game server.
    let gameHandler = SCGameHandler(socket: tcpSocket, reservation: reservation, strategy: strategy)
    gameHandler.handleGame()
}

// Close the socket and the connection with the game server.
tcpSocket.close()

print("Terminating the client!")