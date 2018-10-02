# Swift client for Software-Challenge Germany 2018/2019

[![Build Status](https://travis-ci.com/matthesjh/sc19-swift-client.svg?branch=master)](https://travis-ci.com/matthesjh/sc19-swift-client)

This package contains a simple client written in [Swift](https://swift.org/) for [Software-Challenge Germany](https://www.software-challenge.de/) 2018/2019.

The game of the contest year 2018/2019 is called *Piranhas*. It is played on a board with 10x10 fields. The goal of the game is to unite his piranhas to a single swarm. The complete documentation of the game rules and the XML communication with the game server can be found [here](https://cau-kiel-tech-inf.github.io/socha-enduser-docs/).

## Usage

Please make sure that you have installed the latest Swift toolchain (or at least version 4.2) on your operating system. The latest version of Swift can be found [here](https://swift.org/download/).

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
      The IP address of the host to connect to (default: 127.0.0.1).
  -p, --port:
      The port used for the connection (default: 13050).
  -r, --reservation:
      The reservation code to join a prepared game.
  -s, --strategy:
      The strategy used for the game.
  --help:
      Print this help message.
```