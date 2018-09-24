/// Contains some constants that are used within this package.
struct SCConstants {
    /// The size of the game board.
    static let boardSize = 10
    /// The maximum number of rounds per game.
    static let roundLimit = 30
    /// The maximum number of turns per game.
    static let turnLimit = roundLimit * 2

    // Hide the initializer to not allow instances of this struct.
    private init() { }
}