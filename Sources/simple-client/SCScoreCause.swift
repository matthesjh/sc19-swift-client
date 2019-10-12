/// The reason for the score of a player.
enum SCScoreCause: String, CaseIterable, CustomStringConvertible {
    /// The player didn't violate against the game rules or left the game early.
    case regular = "REGULAR"
    /// The player left the game early (connection loss).
    case left = "LEFT"
    /// The player violated against the game rules.
    case ruleViolation = "RULE_VIOLATION"
    /// The player took too long to respond to a move request.
    case softTimeout = "SOFT_TIMEOUT"
    /// The player didn't respond to the move request.
    case hardTimeout = "HARD_TIMEOUT"
    /// An unknown error occurred during communication.
    case unknown = "UNKNOWN"

    // MARK: - CustomStringConvertible

    var description: String {
        return self.rawValue
    }
}