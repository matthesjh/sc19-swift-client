## 1.7.0 (2020-02-23)

* Added the following methods to the `SCGameState` class
  - `getFields(withState:)`
  - `obstructedFields()`

## 1.6.0 (2019-11-15)

* Added the following properties to the `SCGameState` class
  - `round`
* Added the following constants to the `SCConstants` class
  - `gameIdentifier`
* Fixed a typo in the `SCScoreCause` documentation comments

## 1.5.0 (2019-06-09)

* A game logic can now access the game result received from the game server
* Added the following methods to the `SCGameHandlerDelegate` protocol
  - `onGameResultReceived(_:)`

## 1.4.0 (2019-05-12)

* Refactored some methods in the `SCGameState` class
* Added the following methods to the `SCField` class
  - `hasPiranha(ofPlayer:)`
  - `isCoverable(byPlayer:)`
  - `isSkippable(byPlayer:)`

## 1.3.3 (2019-04-07)

* Added the following methods to the `SCGameState` class
  - `undoLastMove()`

## 1.3.2 (2019-03-26)

* Adjusted the start script to show the installed Swift version
* Added the following methods to the `SCGameState` class
  - `isSwarmConnected(forPlayer:)`

## 1.3.1 (2019-03-07)

* Adjusted the start script to correctly start the executable on the competition system
* Improved the `connect(toHost:withPort:)` method to resolve hostnames that are not IP addresses
* Reduced the maximum blocking time of the `readable` property in the `SCSocket` class from `50ms` to `1ms`

## 1.3.0 (2019-02-22)

* The `fieldsInDirection(ofMove:withDistance:)` method now has an optional return type (`[SCField]?` instead of `[SCField]`)
* Added the following methods to the `SCGameState` class
  - `biggestSwarm(ofPlayer:)`
  - `neighboursOfField(x:y:)`
  - `neighboursOfField(x:y:withState:)`
  - `swarms(ofPlayer:)`
* Improved the following methods in the `SCGameState` class
  - `fieldsInDirection(ofMove:withDistance:)`
  - `moveDistance(x:y:direction:)`
  - `performMove(move:)`
  - `possibleMoves()`
* Improved the documentation comments in the `SCSocket` class

## 1.2.0 (2018-12-29)

* The move distance methods now have an optional return type (`Int?` instead of `Int`)
* A compiler error message will now be shown on unsupported platforms
* Implemented the `CustomStringConvertible` protocol in the `SCGameState` class
* Improved the following methods in the `SCGameState` class
  - `getFields(ofPlayer:)`
  - `moveDistanceDiagonalFalling(x:y:)`
  - `moveDistanceDiagonalRising(x:y:)`

## 1.1.0 (2018-12-14)

* Added a `--version` command-line argument to the executable
* Added the methods `isEmpty()` and `isObstructed()` to the `SCField` class
* Added a subscript to the `SCGameState` class
* Renamed the method `getFieldsOf(player:)` to `getFields(ofPlayer:)` in the `SCGameState` class
* Improved some documentation comments

## 1.0.0 (2018-10-05)

* First release