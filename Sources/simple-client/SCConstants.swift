/// Contains some constants that are used within this package.
struct SCConstants {
    // MARK: - Properties

    /// The size of the game board.
    static let boardSize = 10
    /// The maximum number of piranhas per player.
    static let maxNumberOfPiranhas = (boardSize - 2) * 2
    /// The maximum number of rounds per game.
    static let roundLimit = 30
    /// The maximum number of turns per game.
    static let turnLimit = roundLimit * 2

    // MARK: - Initializers

    // Hide the initializer to not allow instances of this struct.
    private init() { }
}