/// Represents the state of a game, as received from the game server.
class SCGameState {
    // MARK: - Properties

    /// The color of the player starting the game.
    let startPlayer: SCPlayerColor
    /// The color of the current player.
    private(set) var currentPlayer: SCPlayerColor
    /// The current turn number.
    private(set) var turn = 0
    /// The last move that has been performed.
    private(set) var lastMove: SCMove?
    /// The two-dimensional array of fields representing the game board.
    private(set) var board: [[SCField]]

    // MARK: - Initializers

    /// Creates a new game state with the given start player.
    ///
    /// - Parameter startPlayer: The player starting the game.
    init(startPlayer: SCPlayerColor) {
        self.startPlayer = startPlayer
        self.currentPlayer = startPlayer

        // Initialize the board with empty fields.
        self.board = []
        for x in 0..<SCConstants.boardSize {
            var column = [SCField]()
            for y in 0..<SCConstants.boardSize {
                column.append(SCField(x: x, y: y))
            }
            self.board.append(column)
        }
    }

    /// Creates a new game state by copying the given game state.
    ///
    /// - Parameter gameState: The game state to copy.
    init(withGameState gameState: SCGameState) {
        self.startPlayer = gameState.startPlayer
        self.currentPlayer = gameState.currentPlayer
        self.turn = gameState.turn
        self.lastMove = gameState.lastMove
        self.board = gameState.board
    }

    // MARK: - Methods

    /// Returns the field with the given x- and y-coordinate.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the field.
    ///   - y: The y-coordinate of the field.
    ///
    /// - Returns: The field with the given x- and y-coordinate.
    func getField(x: Int, y: Int) -> SCField {
        return self.board[x][y]
    }

    /// Returns the field state of the field with the given x- and y-coordinate.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the field.
    ///   - y: The y-coordinate of the field.
    ///
    /// - Returns: The state of the field.
    func getFieldState(x: Int, y: Int) -> SCFieldState {
        return self.board[x][y].state
    }

    /// Sets the field state of the field with the given x- and y-coordinate to
    /// the given field state.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the field.
    ///   - y: The y-coordinate of the field.
    ///   - state: The new state of the field.
    func setFieldState(x: Int, y: Int, state: SCFieldState) {
        self.board[x][y].state = state
    }

    /// Returns the fields covered by a piranha of the given player.
    ///
    /// - Parameter player: The color of the player to search for on the board.
    ///
    /// - Returns: The array of fields covered by a piranha of the given player.
    func getFields(ofPlayer player: SCPlayerColor) -> [SCField] {
        var fields = [SCField]()

        for column in self.board {
            for field in column {
                if field.state == player.fieldState {
                    fields.append(field)
                }
            }
        }

        return fields
    }

    /// Returns the number of steps that must be taken when moving a piranha
    /// horizontally in the given row.
    ///
    /// - Parameter row: The row of the piranha.
    ///
    /// - Returns: The number of steps that must be taken. If the given row is
    ///   not on the board, `-1` is returned.
    func moveDistanceHorizontal(inRow row: Int) -> Int {
        if row < 0 || row >= SCConstants.boardSize {
            return -1
        }

        var count = 0

        var i = 0
        while i < SCConstants.boardSize {
            if self.board[i][row].hasPiranha() {
                count += 1
            }
            i += 1
        }

        return count
    }

    /// Returns the number of steps that must be taken when moving a piranha
    /// vertically in the given column.
    ///
    /// - Parameter column: The column of the piranha.
    ///
    /// - Returns: The number of steps that must be taken. If the given column
    ///   is not on the board, `-1` is returned.
    func moveDistanceVertical(inColumn column: Int) -> Int {
        if column < 0 || column >= SCConstants.boardSize {
            return -1
        }

        var count = 0

        var i = 0
        while i < SCConstants.boardSize {
            if self.board[column][i].hasPiranha() {
                count += 1
            }
            i += 1
        }

        return count
    }

    /// Returns the number of steps that must be taken when moving a piranha
    /// diagonally (down left to up right) starting at the given x- and
    /// y-coordinate.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the piranha.
    ///   - y: The y-coordinate of the piranha.
    ///
    /// - Returns: The number of steps that must be taken. If the given x- or
    ///   y-coordinate is not on the board, `-1` is returned.
    func moveDistanceDiagonalRising(x: Int, y: Int) -> Int {
        if x < 0 || x >= SCConstants.boardSize
                 || y < 0
                 || y >= SCConstants.boardSize {
            return -1
        }

        var count = 0

        // Move down left.
        var fX = x
        var fY = y
        while fX >= 0 && fY >= 0 {
            if self.board[fX][fY].hasPiranha() {
                count += 1
            }

            fX -= 1
            fY -= 1
        }

        // Move up right.
        fX = x + 1
        fY = y + 1
        while fX < SCConstants.boardSize && fY < SCConstants.boardSize {
            if self.board[fX][fY].hasPiranha() {
                count += 1
            }

            fX += 1
            fY += 1
        }

        return count
    }

    /// Returns the number of steps that must be taken when moving a piranha
    /// diagonally (up left to down right) starting at the given x- and
    /// y-coordinate.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the piranha.
    ///   - y: The y-coordinate of the piranha.
    ///
    /// - Returns: The number of steps that must be taken. If the given x- or
    ///   y-coordinate is not on the board, `-1` is returned.
    func moveDistanceDiagonalFalling(x: Int, y: Int) -> Int {
        if x < 0 || x >= SCConstants.boardSize
                 || y < 0
                 || y >= SCConstants.boardSize {
            return -1
        }

        var count = 0

        // Move down right.
        var fX = x
        var fY = y
        while fX < SCConstants.boardSize && fY >= 0 {
            if self.board[fX][fY].hasPiranha() {
                count += 1
            }

            fX += 1
            fY -= 1
        }

        // Move up left.
        fX = x - 1
        fY = y + 1
        while fX >= 0 && fY < SCConstants.boardSize {
            if self.board[fX][fY].hasPiranha() {
                count += 1
            }

            fX -= 1
            fY += 1
        }

        return count
    }

    /// Returns the number of steps that must be taken when moving a piranha
    /// in the given direction starting at the given x- and y-coordinate.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the piranha.
    ///   - y: The y-coordinate of the piranha.
    ///   - direction: The direction for the piranha.
    ///
    /// - Returns: The number of steps that must be taken. If the given x- or
    ///   y-coordinate is not on the board, `-1` is returned.
    func moveDistance(x: Int, y: Int, direction: SCDirection) -> Int {
        switch direction {
            case .left, .right:
                return self.moveDistanceHorizontal(inRow: y)
            case .down, .up:
                return self.moveDistanceVertical(inColumn: x)
            case .downLeft, .upRight:
                return self.moveDistanceDiagonalRising(x: x, y: y)
            case .downRight, .upLeft:
                return self.moveDistanceDiagonalFalling(x: x, y: y)
        }
    }

    /// Returns the number of steps that must be taken when performing the given
    /// move.
    ///
    /// - Parameter move: The move to be performed.
    ///
    /// - Returns: The number of steps that must be taken. If the x- or
    ///   y-coordinate of the move is not on the board, `-1` is returned.
    func distance(forMove move: SCMove) -> Int {
        return self.moveDistance(x: move.x, y: move.y, direction: move.direction)
    }

    /// Returns the destination field for the given move with the given
    /// distance.
    ///
    /// - Parameters:
    ///   - move: The move to be performed.
    ///   - distance: The number of steps to be taken.
    ///
    /// - Returns: The destination field if it is on the board; otherwise,
    ///   `nil`. If the distance is less than zero, `nil` is returned.
    func destination(forMove move: SCMove, withDistance distance: Int) -> SCField? {
        if distance < 0 {
            return nil
        }

        let (vx, vy) = move.direction.vector
        let fX = move.x + vx * distance
        let fY = move.y + vy * distance

        if fX < 0 || fX >= SCConstants.boardSize
                  || fY < 0
                  || fY >= SCConstants.boardSize {
            return nil
        }

        return self.board[fX][fY]
    }

    /// Returns the fields between the start field of the given move and the
    /// field that is reached by performing the move with the given distance.
    ///
    /// - Parameters:
    ///   - move: The move to be performed.
    ///   - distance: The number of steps to be taken.
    ///
    /// - Returns: The fields between the start and end field. If the distance
    ///   is less than or equal to zero, an empty array is returned.
    func fieldsInDirection(ofMove move: SCMove, withDistance distance: Int) -> [SCField] {
        if distance <= 0 {
            return []
        }

        let (vx, vy) = move.direction.vector
        let fX = move.x + vx * distance
        let fY = move.y + vy * distance

        if fX < 0 || fX >= SCConstants.boardSize
                  || fY < 0
                  || fY >= SCConstants.boardSize {
            return []
        }

        var fields = [SCField]()

        var i = 1
        while i < distance {
            fields.append(self.board[move.x + vx * i][move.y + vy * i])
            i += 1
        }

        return fields
    }

    /// Returns the possible moves of the current player.
    ///
    /// - Returns: The array of possible moves.
    func possibleMoves() -> [SCMove] {
        var moves = [SCMove]()

        let opponentFieldState = self.currentPlayer.opponentColor.fieldState

        for field in self.getFields(ofPlayer: self.currentPlayer) {
            dirLoop: for dir in SCDirection.allCases {
                let move = SCMove(x: field.x, y: field.y, direction: dir)
                let distance = self.distance(forMove: move)

                if distance > 0 {
                    if let destField = self.destination(forMove: move, withDistance: distance) {
                        for f in self.fieldsInDirection(ofMove: move, withDistance: distance) {
                            if f.state == opponentFieldState {
                                continue dirLoop
                            }
                        }

                        if destField.state == .obstructed
                               || destField.state == self.currentPlayer.fieldState {
                            continue dirLoop
                        }

                        moves.append(move)
                    }
                }
            }
        }

        return moves
    }

    /// Performs the given move on the game board.
    ///
    /// - Returns: `true` if the move could be performed; otherwise, `false`.
    func performMove(move: SCMove) -> Bool {
        let x = move.x
        let y = move.y

        if self.turn >= SCConstants.turnLimit
               || x < 0
               || x >= SCConstants.boardSize
               || y < 0
               || y >= SCConstants.boardSize
               || self.board[x][y].state != self.currentPlayer.fieldState {
            return false
        }

        let distance = self.distance(forMove: move)
        if distance > 0 {
            if let destField = self.destination(forMove: move, withDistance: distance) {
                for f in self.fieldsInDirection(ofMove: move, withDistance: distance) {
                    if f.state == self.currentPlayer.opponentColor.fieldState {
                        return false
                    }
                }

                if destField.state == .obstructed
                       || destField.state == self.currentPlayer.fieldState {
                    return false
                }

                self.board[x][y].state = .empty
                self.board[destField.x][destField.y].state = self.currentPlayer.fieldState
                self.turn += 1
                self.currentPlayer.switchColor()
                self.lastMove = move

                return true
            }
        }

        return false
    }
}