/// The final result of a game.
struct SCGameResult {
    // MARK: - Properties

    /// The scores of the players.
    let scores: [SCScore]
    /// The winner of the game.
    let winner: SCWinner?

    // MARK: - Initializers

    /// Creates a new game result with the given player scores and the given
    /// winner of the game.
    ///
    /// - Parameters:
    ///   - scores: The scores of the players.
    ///   - winner: The winner of the game.
    init(scores: [SCScore], winner: SCWinner? = nil) {
        self.scores = scores
        self.winner = winner
    }
}