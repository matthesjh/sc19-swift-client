#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

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

/// Prints the help message into the standard output.
func printUsageMessage() {
    print("""
        Usage: simple-client [options]
          -h, --host:
              The IP address of the host to connect to (default: \(defaultHost)).
          -p, --port:
              The port used for the connection (default: \(defaultPort)).
          -r, --reservation:
              The reservation code to join a prepared game.
          --help:
              Print this help message.
        """)
}

/// Exits the program with the given error mesage.
///
/// - Parameter error: The error message to print into the standard output.
func exitWith(error: String) {
    if !error.isEmpty {
        print("ERROR: \(error)")
    }

    printUsageMessage()
    exit(EXIT_FAILURE)
}

/// The command-line arguments.
let argv = CommandLine.arguments
/// The number of command-line arguments.
let argc = argv.count

// Parse the command-line arguments.
var i = 0
while i < argc {
    let arg = argv[i]

    if arg == "--help" {
        printUsageMessage()
        exit(EXIT_SUCCESS)
    } else if arg.hasPrefix("-") {
        i += 1

        if i < argc {
            let argValue = argv[i]

            switch arg {
                case "-h", "--host":
                    host = argValue
                case "-p", "--port":
                    if let portValue = UInt16(argValue) {
                        port = portValue
                    } else {
                        exitWith(error: "The value \"\(argValue)\" can not be converted to a port number!")
                    }
                case "-r", "--reservation":
                    reservation = argValue
                default:
                    exitWith(error: "Unrecognized option \"\(arg)\"!")
            }
        } else {
            exitWith(error: "Missing value for the option \"\(arg)\"!")
        }
    }

    i += 1
}

if host.isEmpty || host == "localhost" {
    host = defaultHost
}

print("HOST: \(host)")
print("PORT: \(port)")
print("RESERVATION: \(reservation)")