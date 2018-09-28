/// The protocol which must be implemented by a game logic.
protocol SCGameHandlerDelegate {
    /// Sent by the game handler when the game has been ended.
    func onGameEnded()

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

class SCGameHandler {
    let socket: SCSocket
    let strategy: String
    let reservation: String

    init(socket: SCSocket, reservation: String, strategy: String) {
        self.socket = socket
        self.strategy = strategy
        self.reservation = reservation
    }

    func handleGame() {

    }
}