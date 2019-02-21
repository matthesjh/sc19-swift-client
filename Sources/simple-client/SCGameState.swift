/// Represents the state of a game, as received from the game server.
class SCGameState: CustomStringConvertible {
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
        let range = 0..<SCConstants.boardSize
        self.board = range.map { x in
            range.map { SCField(x: x, y: $0) }
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

    // MARK: - Subscripts

    /// Accesses the field state of the field with the given x- and
    /// y-coordinate.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the field.
    ///   - y: The y-coordinate of the field.
    subscript(x: Int, y: Int) -> SCFieldState {
        get {
            return self.board[x][y].state
        }
        set {
            self.board[x][y].state = newValue
        }
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
        return self[x, y]
    }

    /// Sets the field state of the field with the given x- and y-coordinate to
    /// the given field state.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the field.
    ///   - y: The y-coordinate of the field.
    ///   - state: The new state of the field.
    func setFieldState(x: Int, y: Int, state: SCFieldState) {
        self[x, y] = state
    }

    /// Returns the fields covered by a piranha of the given player.
    ///
    /// - Parameter player: The color of the player to search for on the board.
    ///
    /// - Returns: The array of fields covered by a piranha of the given player.
    func getFields(ofPlayer player: SCPlayerColor) -> [SCField] {
        return self.board.flatMap { $0.filter { $0.state == player.fieldState } }
    }

    /// Returns the neighbouring fields of the field with the given x- and
    /// y-coordinate.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the field.
    ///   - y: The y-coordinate of the field.
    ///
    /// - Returns: The array of neighbouring fields. If the given x- or
    ///   y-coordinate is not on the board, `nil` is returned.
    func getNeighboursOfField(x: Int, y: Int) -> [SCField]? {
        guard x >= 0, x < SCConstants.boardSize,
              y >= 0, y < SCConstants.boardSize else {
            return nil
        }

        var fields = [SCField]()

        for dir in SCDirection.allCases {
            let (vx, vy) = dir.vector
            let fX = x + vx
            let fY = y + vy

            guard fX >= 0, fX < SCConstants.boardSize,
                  fY >= 0, fY < SCConstants.boardSize else {
                continue
            }

            fields.append(self.board[fX][fY])
        }

        return fields
    }

    /// Returns the neighbouring fields of the field with the given x- and
    /// y-coordinate which have the given field state.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the field.
    ///   - y: The y-coordinate of the field.
    ///   - state: The field state to search for on the board.
    ///
    /// - Returns: The array of neighbouring fields with the given field state.
    ///   If the given x- or y-coordinate is not on the board, `nil` is
    ///   returned.
    func getNeighboursOfField(x: Int, y: Int, withState state: SCFieldState) -> [SCField]? {
        return self.getNeighboursOfField(x: x, y: y)?.filter { $0.state == state }
    }

    /// Returns the number of steps that must be taken when moving a piranha
    /// horizontally in the given row.
    ///
    /// - Parameter row: The row of the piranha.
    ///
    /// - Returns: The number of steps that must be taken. If the given row is
    ///   not on the board, `nil` is returned.
    func moveDistanceHorizontal(inRow row: Int) -> Int? {
        guard row >= 0, row < SCConstants.boardSize else {
            return nil
        }

        var count = 0

        for i in 0..<SCConstants.boardSize {
            if self.board[i][row].hasPiranha() {
                count += 1
            }
        }

        return count
    }

    /// Returns the number of steps that must be taken when moving a piranha
    /// vertically in the given column.
    ///
    /// - Parameter column: The column of the piranha.
    ///
    /// - Returns: The number of steps that must be taken. If the given column
    ///   is not on the board, `nil` is returned.
    func moveDistanceVertical(inColumn column: Int) -> Int? {
        guard column >= 0, column < SCConstants.boardSize else {
            return nil
        }

        var count = 0

        for i in 0..<SCConstants.boardSize {
            if self.board[column][i].hasPiranha() {
                count += 1
            }
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
    ///   y-coordinate is not on the board, `nil` is returned.
    func moveDistanceDiagonalRising(x: Int, y: Int) -> Int? {
        guard x >= 0, x < SCConstants.boardSize,
              y >= 0, y < SCConstants.boardSize else {
            return nil
        }

        var count = 0

        let (min, max) = x < y ? (x, y) : (y, x)
        for i in min * -1 ..< SCConstants.boardSize - max {
            if self.board[x + i][y + i].hasPiranha() {
                count += 1
            }
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
    ///   y-coordinate is not on the board, `nil` is returned.
    func moveDistanceDiagonalFalling(x: Int, y: Int) -> Int? {
        guard x >= 0, x < SCConstants.boardSize,
              y >= 0, y < SCConstants.boardSize else {
            return nil
        }

        var count = 0

        let lower = min(x, SCConstants.boardSize - 1 - y) * -1
        let upper = min(SCConstants.boardSize - 1 - x, y)
        for i in lower...upper {
            if self.board[x + i][y - i].hasPiranha() {
                count += 1
            }
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
    ///   y-coordinate is not on the board, `nil` is returned.
    func moveDistance(x: Int, y: Int, direction: SCDirection) -> Int? {
        switch direction {
            case .left, .right:
                guard x >= 0, x < SCConstants.boardSize else {
                    return nil
                }

                return self.moveDistanceHorizontal(inRow: y)
            case .down, .up:
                guard y >= 0, y < SCConstants.boardSize else {
                    return nil
                }

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
    ///   y-coordinate of the move is not on the board, `nil` is returned.
    func distance(forMove move: SCMove) -> Int? {
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
        guard distance >= 0 else {
            return nil
        }

        let (vx, vy) = move.direction.vector
        let fX = move.x + vx * distance
        let fY = move.y + vy * distance

        guard fX >= 0, fX < SCConstants.boardSize,
              fY >= 0, fY < SCConstants.boardSize else {
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
    ///   is less than or equal to zero or the start or end field is not on the
    ///   board, `nil` is returned.
    func fieldsInDirection(ofMove move: SCMove, withDistance distance: Int) -> [SCField]? {
        guard move.x >= 0, move.x < SCConstants.boardSize,
              move.y >= 0, move.y < SCConstants.boardSize,
              distance > 0 else {
            return nil
        }

        let (vx, vy) = move.direction.vector
        let fX = move.x + vx * distance
        let fY = move.y + vy * distance

        guard fX >= 0, fX < SCConstants.boardSize,
              fY >= 0, fY < SCConstants.boardSize else {
            return nil
        }

        return (1..<distance).map { self.board[move.x + vx * $0][move.y + vy * $0] }
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

                guard let distance = self.distance(forMove: move),
                      let destField = self.destination(forMove: move, withDistance: distance),
                      destField.state == .empty || destField.state == opponentFieldState else {
                    continue dirLoop
                }

                let (vx, vy) = dir.vector
                for f in (1..<distance).map({ self.board[move.x + vx * $0][move.y + vy * $0] }) {
                    if f.state == opponentFieldState {
                        continue dirLoop
                    }
                }

                moves.append(move)
            }
        }

        return moves
    }

    /// Performs the given move on the game board.
    ///
    /// - Returns: `true` if the move could be performed; otherwise, `false`.
    func performMove(move: SCMove) -> Bool {
        let opponentFieldState = self.currentPlayer.opponentColor.fieldState

        guard self.turn < SCConstants.turnLimit,
              let distance = self.distance(forMove: move),
              self[move.x, move.y] == self.currentPlayer.fieldState,
              let destField = self.destination(forMove: move, withDistance: distance),
              destField.state == .empty || destField.state == opponentFieldState else {
            return false
        }

        let (vx, vy) = move.direction.vector
        for f in (1..<distance).map({ self.board[move.x + vx * $0][move.y + vy * $0] }) {
            if f.state == opponentFieldState {
                return false
            }
        }

        self[move.x, move.y] = .empty
        self[destField.x, destField.y] = self.currentPlayer.fieldState
        self.turn += 1
        self.currentPlayer.switchColor()
        self.lastMove = move

        return true
    }

    // MARK: - CustomStringConvertible

    var description: String {
        let border = String(repeating: "─", count: 2 * SCConstants.boardSize)

        let range = 0..<SCConstants.boardSize
        let rows = range.reversed().reduce(into: "\n") { res, y in
            res += range.reduce(into: "│ ") {
                switch self[$1, y] {
                    case .red:
                        $0 += "R "
                    case .blue:
                        $0 += "B "
                    case .obstructed:
                        $0 += "X "
                    case .empty:
                        $0 += "- "
                }
            } + "│\n"
        }

        return "┌" + border + "─┐" + rows + "└" + border + "─┘"
    }
}