# Swift client for Software-Challenge Germany 2018/2019

[![Build Status](https://travis-ci.com/matthesjh/sc19-swift-client.svg?branch=master)](https://travis-ci.com/matthesjh/sc19-swift-client)
![Build package](https://github.com/matthesjh/sc19-swift-client/workflows/Build%20package/badge.svg)
[![Swift](https://img.shields.io/badge/swift-%3E%3D%204.2.1-brightgreen.svg?logo=swift)](https://swift.org/)
![Supported Platforms](https://img.shields.io/badge/platform-macOS%20%7C%20linux-lightgrey.svg)

This package contains a simple client written in [Swift](https://swift.org/) for [Software-Challenge Germany](https://www.software-challenge.de/) 2018/2019.

The game of the contest year 2018/2019 is called *Piranhas*. It is played on a board with 10x10 fields. The goal of the game is to unite his piranhas to a single swarm. The complete documentation of the game rules and the XML communication with the game server can be found [here](https://cau-kiel-tech-inf.github.io/socha-enduser-docs/).

## Usage

Please make sure that you have installed the latest Swift toolchain (or at least version 4.2.1) on your operating system. The latest version of Swift can be found [here](https://swift.org/download/).

To build and run the executable of the simple client, use the `run` command of the Swift Package Manager.

```shell
swift run
```

If you want to use e.g. another host address or port for the simple client, then you can pass additional arguments to the `run` command of the Swift Package Manager. Please note that you need to specify the name of the executable when using additional arguments.

```shell
swift run simple-client -h 127.0.0.1 -p 13050
```

The simple client supports the following command-line arguments.

```
Usage: simple-client [options]
  -h, --host:
      The IP address or name of the host to connect to (default: 127.0.0.1).
  -p, --port:
      The port used for the connection (default: 13050).
  -r, --reservation:
      The reservation code to join a prepared game.
  -s, --strategy:
      The strategy used for the game.
  --help:
      Print this help message.
  --version:
      Print the version number.
```

## Creating an archive for upload

In order to use the simple client on the [competition system](https://contest.software-challenge.de/) (a.k.a. Wettkampfsystem), a zip archive must be created that contains a start script and the compiled executable. To create such an archive, run the following commands on the terminal.

```shell
chmod u+x scripts/zip-client.sh
scripts/zip-client.sh
```

The resulting archive (`simple-client.zip`) can then be uploaded to the competition system. Please make sure that you select the start script (`start-client.sh`) as the main file in the uploading process.

**Note:** The above script ([`zip-client.sh`](scripts/zip-client.sh)) builds the client with the `release` configuration and calls the Swift compiler with the `-O` flag to optimize the executable for speed.

## Customizing the logic

To customize the logic of the simple client to your own needs, simply adjust the [`onMoveRequested()`](Sources/simple-client/SCGameLogic.swift#L34) method in the `SCGameLogic.swift` class.

```swift
func onMoveRequested() -> SCMove? {
    print("*** A move is requested by the game server!")

    // TODO: Add your own logic here.

    return self.gameState.possibleMoves().randomElement()
}
```

If you want to return e.g. the last possible move, the method can be changed as follows.

```swift
func onMoveRequested() -> SCMove? {
    print("*** A move is requested by the game server!")

    return self.gameState.possibleMoves().last
}
```

In addition to the default logic class, you can also implement your own logic classes. To use one of your own logic classes, the simple client offers the possibility to select a strategy (logic class) based on the value of a command-line argument (`-s` or `--strategy`). By default, this feature is disabled. To enable the feature, create a logic instance based on the `strategy` property of the `SCGameHandler.swift` class. This can be done by replacing the existing [code line](Sources/simple-client/SCGameHandler.swift#L211) with a `switch`-statement like the following.

```swift
switch self.strategy {
    case "winner":
        self.delegate = SCWinnerLogic(player: self.playerColor)
    case "crazy":
        self.delegate = SCCrazyGameLogic(player: self.playerColor)
    case "another_logic":
        self.delegate = AnotherLogic(player: self.playerColor)
    // ...
    default:
        self.delegate = SCGameLogic(player: self.playerColor)
}
```

## Renaming the client

If you want to change the name of the simple client, you have to adjust the target name in the [`Package.swift`](Package.swift#L8) file and the directory name in the [`Sources`](Sources) folder. Furthermore the `EXECUTABLE_NAME` variable in the [shell scripts](scripts) and the `executableName` constant in the [`main.swift`](Sources/simple-client/main.swift#L10) file needs to be changed.

## Troubleshooting

Should you encounter an error or unexpected behavior while using the simple client, you may be able to resolve the problem by following the advice below.

- **Increase the TCP socket timeout:** On some systems the current socket timeout of `1ms` results in fatal errors before sending the first move. To prevent this, you can increase the [socket timeout](Sources/simple-client/SCSocket.swift#L87) to a higher value. Any value greater than or equal to `5000` (which corresponds to `5ms`) should resolve the problem on most systems.

If none of these tips help and you feel that you have encountered a bug, feel free to open an issue. Please describe your problem as accurately as you can and include steps to reproduce the error if possible. Note that a GitHub account is required to create a new issue. You can also instruct your tutor to do it for you.