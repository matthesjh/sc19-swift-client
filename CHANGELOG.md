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