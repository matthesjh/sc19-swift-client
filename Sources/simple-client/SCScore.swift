/// The score of a player.
struct SCScore {
    // MARK: - Properties

    /// The reason of the score.
    let cause: SCScoreCause
    /// The textual representation of the score reason.
    let reason: String?
    /// The values associated with the score.
    lazy var values = [Float]()

    // MARK: - Initializers

    /// Creates a new score with the given reason and the optional textual
    /// representation of the reason.
    ///
    /// - Parameters:
    ///   - cause: The reason of the score.
    ///   - reason: The textual representation of the score reason.
    init(cause: SCScoreCause, reason: String? = nil) {
        self.cause = cause
        self.reason = reason
    }
}