/// A field on the game board. It consists of an x- and y-coordinate and a field
/// state.
struct SCField {
    /// The x-coordinate of the field.
    let x: Int
    /// The y-coordinate of the field.
    let y: Int
    /// The state of the field.
    var state: SCFieldState

    /// Creates a new field with the given x- and y-coordinate and the given
    /// field state. If no state is provided an empty field is created.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the field.
    ///   - y: The y-coordinate of the field.
    ///   - state: The state of the field.
    init(x: Int, y: Int, state: SCFieldState = .empty) {
        self.x = x
        self.y = y
        self.state = state
    }

    /// Returns a boolean value indicating whether the field is covered by a red
    /// or blue piranha.
    ///
    /// - Returns: `true` if the field is covered by a red or blue piranha;
    ///   otherwise, `false`.
    func hasPiranha() -> Bool {
        return self.state == .red || self.state == .blue
    }
}