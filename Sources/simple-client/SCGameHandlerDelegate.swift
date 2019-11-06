/// The protocol which must be implemented by a game logic.
protocol SCGameHandlerDelegate {
    /// Sent by the game handler when the game has been ended.
    func onGameEnded()

    /// Sent by the game handler when the game result has been received.
    ///
    /// - Parameter gameResult: The final result of the game.
    func onGameResultReceived(_ gameResult: SCGameResult)

    /// Sent by the game handler when the game state has been updated.
    ///
    /// - Parameter gameState: The new game state.
    func onGameStateUpdated(_ gameState: SCGameState)

    /// Sent by the game handler when a move is requested by the game server.
    ///
    /// - Returns: The move sent to the game server or `nil` if no move should
    ///   be sent to the game server.
    func onMoveRequested() -> SCMove?
}