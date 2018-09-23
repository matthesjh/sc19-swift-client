/// A field on the game board. It consists of an x- and y-coordinate and a
/// field state.
struct SCField {
    /// The x-coordinate of the field.
    let x: Int
    /// The y-coordinate of the field.
    let y: Int
    /// The state of the field.
    var state: SCFieldState

    /// Creates a new field with the given x- and y-coordinate and the given
    /// field state.
    ///
    /// - Parameter x: The x-coordinate of the field.
    /// - Parameter y: The y-coordinate of the field.
    /// - Parameter state: The state of the field.
    init(x: Int, y: Int, state: SCFieldState) {
        self.x = x
        self.y = y
        self.state = state
    }

    /// Creates an empty field with the given x- and y-coordinate.
    ///
    /// - Parameter x: The x-coordinate of the field.
    /// - Parameter y: The y-coordinate of the field.
    init(x: Int, y: Int) {
        self.init(x: x, y: y, state: .empty)
    }
}