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

    /// The two-dimensional vector describing the direction.
    var vector: (vx: Int, vy: Int) {
        switch self {
            case .up:
                return (0, 1)
            case .upRight:
                return (1, 1)
            case .right:
                return (1, 0)
            case .downRight:
                return (1, -1)
            case .down:
                return (0, -1)
            case .downLeft:
                return (-1, -1)
            case .left:
                return (-1, 0)
            case .upLeft:
                return (-1, 1)
        }
    }
}