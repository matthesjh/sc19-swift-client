/// The possible colors of a player.
enum SCPlayerColor: String, CustomStringConvertible {
    /// The color of the red player.
    case red = "red"
    /// The color of the blue player.
    case blue = "blue"

    /// Returns the color of the opponent player.
    ///
    /// - Returns: The color of the opponent player.
    func opponentColor() -> SCPlayerColor {
        return self == .red ? .blue : .red
    }

    var description: String {
        return self.rawValue
    }
}