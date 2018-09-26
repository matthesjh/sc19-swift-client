/// The possible colors of a player.
enum SCPlayerColor: String, CaseIterable, CustomStringConvertible {
    /// The color of the red player.
    case red = "RED"
    /// The color of the blue player.
    case blue = "BLUE"

    /// Returns the color of the opponent player.
    ///
    /// - Returns: The color of the opponent player.
    func opponentColor() -> SCPlayerColor {
        return self == .red ? .blue : .red
    }

    /// Switches the color to the color of the opponent player.
    mutating func switchColor() {
        self = self.opponentColor()
    }

    var description: String {
        return self.rawValue
    }
}