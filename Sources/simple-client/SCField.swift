/// A field on the game board. It consists of an x- and y-coordinate and a field
/// state.
struct SCField {
    // MARK: - Properties

    /// The x-coordinate of the field.
    let x: Int
    /// The y-coordinate of the field.
    let y: Int
    /// The state of the field.
    var state: SCFieldState

    // MARK: - Initializers

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

    // MARK: - Methods

    /// Returns a Boolean value indicating whether the field is covered by a red
    /// or blue piranha.
    ///
    /// - Returns: `true` if the field is covered by a red or blue piranha;
    ///   otherwise, `false`.
    func hasPiranha() -> Bool {
        return self.state == .red || self.state == .blue
    }

    /// Returns a Boolean value indicating whether the field is covered by a
    /// piranha of the given player.
    ///
    /// - Parameter player: The color of the player.
    ///
    /// - Returns: `true` if the field is covered by a piranha of the given
    ///   player; otherwise, `false`.
    func hasPiranha(ofPlayer player: SCPlayerColor) -> Bool {
        return self.state == player.fieldState
    }

    /// Returns a Boolean value indicating whether the field is empty.
    ///
    /// - Returns: `true` if the field is empty; otherwise, `false`.
    func isEmpty() -> Bool {
        return self.state == .empty
    }

    /// Returns a Boolean value indicating whether the field is obstructed.
    ///
    /// - Returns: `true` if the field is obstructed; otherwise, `false`.
    func isObstructed() -> Bool {
        return self.state == .obstructed
    }

    /// Returns a Boolean value indicating whether the field can be skipped by
    /// the player with the given color.
    ///
    /// A player can skip a field if it is not covered by a piranha of the
    /// opponent player.
    ///
    /// - Parameter player: The color of the player who wants to skip the field.
    ///
    /// - Returns: `true` if the field can be skipped; otherwise, `false`.
    func isSkippable(byPlayer player: SCPlayerColor) -> Bool {
        return self.state != player.opponentColor.fieldState
    }
}