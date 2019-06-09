/// The winner of a game.
struct SCWinner {
    // MARK: - Properties

    /// The name of the player who won the game.
    let displayName: String
    /// The color of the player who won the game.
    let player: SCPlayerColor

    // MARK: - Initializers

    /// Creates a new winner with the given name and color of the player who won
    /// the game.
    ///
    /// - Parameters:
    ///   - displayName: The name of the player who won the game.
    ///   - player: The color of the player who won the game.
    init(displayName: String, player: SCPlayerColor) {
        self.displayName = displayName
        self.player = player
    }
}