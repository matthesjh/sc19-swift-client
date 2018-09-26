/// The direction of a move.
enum SCDirection: String, CaseIterable, CustomStringConvertible {
    /// Move to north.
    case up = "UP"
    /// Move to northeast.
    case upRight = "UP_RIGHT"
    /// Move to east.
    case right = "RIGHT"
    /// Move to southeast.
    case downRight = "DOWN_RIGHT"
    /// Move to south.
    case down = "DOWN"
    /// Move to southwest.
    case downLeft = "DOWN_LEFT"
    /// Move to west.
    case left = "LEFT"
    /// Move to northwest.
    case upLeft = "UP_LEFT"

    var description: String {
        return self.rawValue
    }
}