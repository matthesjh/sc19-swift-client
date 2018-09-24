/// The logic of the simple client.
class SCGameLogic: SCGameHandlerDelegate {
    // MARK: - Properties

    /// The current game state.
    private var gameState: SCGameState!
    /// The color of the player using this game logic.
    private let player: SCPlayerColor

    // MARK: - Initializers

    /// Creates a new game logic with the given player color.
    ///
    /// - Parameter player: The color of the player using this game logic.
    init(player: SCPlayerColor) {
        self.player = player
    }

    // MARK: - SCGameHandlerDelegate

    func onGameEnded() {
        print("*** The game has been ended!")
    }

    func onGameStateUpdated(_ gameState: SCGameState) {
        print("*** The game state has been updated!")
        self.gameState = gameState
    }

    func onMoveRequested() -> SCMove? {
        print("*** A move is requested by the game server!")
        return self.gameState.possibleMoves().randomElement()
    }
}