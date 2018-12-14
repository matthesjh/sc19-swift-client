/// A move for a piranha. It consists of the x- and y-coordinate of the piranha
/// and a direction.
struct SCMove {
    // MARK: - Properties

    /// The x-coordinate of the piranha.
    let x: Int
    /// The y-coordinate of the piranha.
    let y: Int
    /// The direction of the move.
    let direction: SCDirection
    /// The debug hints associated with the move.
    lazy var debugHints = [String]()

    // MARK: - Initializers

    /// Creates a new move for the piranha with the given x- and y-coordinate
    /// and the given direction.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the piranha.
    ///   - y: The y-coordinate of the piranha.
    ///   - direction: The direction of the move.
    init(x: Int, y: Int, direction: SCDirection) {
        self.x = x
        self.y = y
        self.direction = direction
    }
}