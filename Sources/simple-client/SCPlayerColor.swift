/// The possible colors of a player.
enum SCPlayerColor: String, CaseIterable, CustomStringConvertible {
    /// The color of the red player.
    case red = "RED"
    /// The color of the blue player.
    case blue = "BLUE"

    // MARK: - Properties

    /// The color of the opponent player.
    var opponentColor: SCPlayerColor {
        return self == .red ? .blue : .red
    }

    /// The corresponding field state for the player color.
    var fieldState: SCFieldState {
        return self == .red ? .red : .blue
    }

    // MARK: - Methods

    /// Switches the color to the color of the opponent player.
    mutating func switchColor() {
        self = self.opponentColor
    }

    // MARK: - CustomStringConvertible

    var description: String {
        return self.rawValue
    }
}