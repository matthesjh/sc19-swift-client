/// A move for a piranha. It consists of the x- and y-coordinate of the piranha
/// and a direction.
struct SCMove {
    /// The x-coordinate of the piranha.
    let x: Int
    /// The y-coordinate of the piranha.
    let y: Int
    /// The direction of the move.
    let direction: SCDirection
    /// The debug hints associated with the move.
    lazy var debugHints = [String]()

    /// Creates a new move for the piranha with the given x- and y-coordinate
    /// and the given direction.
    ///
    /// - Parameter x: The x-coordinate of the piranha.
    /// - Parameter y: The y-coordinate of the piranha.
    /// - Parameter direction: The direction of the move.
    init(x: Int, y: Int, direction: SCDirection) {
        self.x = x
        self.y = y
        self.direction = direction
    }
}