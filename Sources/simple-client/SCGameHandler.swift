import Foundation

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

/// The game handler is responsible for the communication with the game server
/// and the selection of the game logic.
class SCGameHandler: NSObject, XMLParserDelegate {
    // MARK: - Properties

    /// The TCP socket used for the communication with the game server.
    private let socket: SCSocket
    /// The reservation code to join a prepared game.
    private let reservation: String
    /// The strategy selected by the user.
    private let strategy: String

    /// The room id associated with the joined game.
    private var roomId: String!
    /// The player color of the delegate (game logic).
    private var playerColor: SCPlayerColor!
    /// The current state of the game.
    private var gameState: SCGameState!
    /// Indicates whether the game state has been initially created.
    private var gameStateCreated = false
    /// Indicates whether the game loop should be left.
    private var leaveGame = false

    /// The current player score which is parsed.
    private var score: SCScore!
    /// The scores of the players.
    private var scores = [SCScore]()
    /// The winner of the game.
    private var winner: SCWinner?
    /// Indicates whether the game result has been received.
    private var gameResultReceived = false

    /// The characters found by the parser.
    private var foundChars = ""

    /// The delegate (game logic) which handles the requests of the game server.
    var delegate: SCGameHandlerDelegate?

    // MARK: - Initializers

    /// Creates a new game handler with the given TCP socket, the given
    /// reservation code and the given strategy.
    ///
    /// The TCP socket must already be connected before using this initializer.
    ///
    /// - Parameters:
    ///   - socket: The socket used for the communication with the game server.
    ///   - reservation: The reservation code to join a prepared game.
    ///   - strategy: The selected strategy.
    init(socket: SCSocket, reservation: String, strategy: String) {
        self.socket = socket
        self.reservation = reservation
        self.strategy = strategy
    }

    // MARK: - Methods

    /// Handles the game.
    func handleGame() {
        if self.reservation.isEmpty {
            // Join a game.
            self.socket.send(message: "<protocol><join gameType=\"swc_2019_piranhas\" />")
        } else {
            // Join a prepared game.
            self.socket.send(message: "<protocol><joinPrepared reservationCode=\"\(self.reservation)\" />")
        }

        // The root element for the received XML document. A temporary fix for
        // the XMLParser.
        guard let rootElem = "<root>".data(using: .utf8) else {
            return
        }

        // Loop until the game is over.
        while !self.leaveGame {
            // Receive the message from the game server.
            var data = Data()
            self.socket.receive(into: &data)

            // Parse the received XML document.
            let parser = XMLParser(data: rootElem + data)
            parser.delegate = self
            _ = parser.parse()
        }
    }

    /// Exits the game with the given error message.
    ///
    /// - Parameter error: The error message to print into the standard output.
    private func exitGame(withError error: String = "") {
        if !error.isEmpty {
            print("ERROR: \(error)")
        }

        self.leaveGame = true
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        // Reset the found characters.
        self.foundChars = ""

        switch elementName {
            case "data":
                // Check whether a class attribute exists.
                guard let classAttr = attributeDict["class"] else {
                    parser.abortParsing()
                    self.exitGame(withError: "The class attribute of the data element is missing!")
                    break
                }

                switch classAttr {
                    case "result":
                        self.gameResultReceived = true
                    case "sc.framework.plugins.protocol.MoveRequest":
                        guard var move = self.delegate?.onMoveRequested() else {
                            parser.abortParsing()
                            self.exitGame(withError: "No move has been sent!")
                            break
                        }

                        // Send the move returned by the game logic to the game
                        // server.
                        let hints = move.debugHints.reduce(into: "") { $0 += "<hint content=\"\($1)\" />" }
                        let mv = "<data class=\"move\" x=\"\(move.x)\" y=\"\(move.y)\" direction=\"\(move.direction)\">\(hints)</data>"
                        self.socket.send(message: "<room roomId=\"\(self.roomId!)\">\(mv)</room>")
                    case "welcomeMessage":
                        guard let colorAttr = attributeDict["color"],
                              let color = SCPlayerColor(rawValue: colorAttr.uppercased()) else {
                            parser.abortParsing()
                            self.exitGame(withError: "The player color of the welcome message is missing or could not be parsed!")
                            break
                        }

                        // Save the player color of this game client.
                        self.playerColor = color
                    default:
                        break
                }
            case "field":
                if !self.gameStateCreated {
                    guard let xAttr = attributeDict["x"], let x = Int(xAttr),
                          let yAttr = attributeDict["y"], let y = Int(yAttr),
                          let stateAttr = attributeDict["state"],
                          let state = SCFieldState(rawValue: stateAttr) else {
                        parser.abortParsing()
                        self.exitGame(withError: "The field could not be parsed!")
                        break
                    }

                    // Update the field on the board.
                    self.gameState[x, y] = state
                }
            case "joined":
                guard let roomId = attributeDict["roomId"] else {
                    parser.abortParsing()
                    self.exitGame(withError: "The room ID is missing!")
                    break
                }

                // Save the room id of the game.
                self.roomId = roomId
            case "lastMove":
                guard let xAttr = attributeDict["x"], let x = Int(xAttr),
                      let yAttr = attributeDict["y"], let y = Int(yAttr),
                      let dirAttr = attributeDict["direction"],
                      let dir = SCDirection(rawValue: dirAttr) else {
                    parser.abortParsing()
                    self.exitGame(withError: "The last move could not be parsed!")
                    break
                }

                // Perform the last move on the game state.
                if !self.gameState.performMove(move: SCMove(x: x, y: y, direction: dir)) {
                    parser.abortParsing()
                    self.exitGame(withError: "The last move could not be performed on the game state!")
                }
            case "left":
                // Leave the game.
                parser.abortParsing()
                self.delegate?.onGameEnded()
                self.exitGame()
            case "score":
                guard let causeAttr = attributeDict["cause"],
                      let cause = SCScoreCause(rawValue: causeAttr) else {
                    parser.abortParsing()
                    self.exitGame(withError: "The score could not be parsed!")
                    break
                }

                // Create the score object.
                self.score = SCScore(cause: cause, reason: attributeDict["reason"])
            case "state":
                if !self.gameStateCreated {
                    guard let startPlayerAttr = attributeDict["startPlayerColor"],
                          let startPlayer = SCPlayerColor(rawValue: startPlayerAttr) else {
                        parser.abortParsing()
                        self.exitGame(withError: "The initial game state could not be parsed!")
                        break
                    }

                    // Create the initial game state.
                    self.gameState = SCGameState(startPlayer: startPlayer)

                    // TODO: Select the game logic based on the strategy.

                    // Create the game logic.
                    self.delegate = SCGameLogic(player: self.playerColor)
                }
            case "winner":
                guard let displayName = attributeDict["displayName"],
                      let colorAttr = attributeDict["color"],
                      let color = SCPlayerColor(rawValue: colorAttr) else {
                    parser.abortParsing()
                    self.exitGame(withError: "The winner could not be parsed!")
                    break
                }

                // Save the winner of the game.
                self.winner = SCWinner(displayName: displayName, player: color)
            default:
                break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.foundChars += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
            case "data":
                if self.gameResultReceived {
                    // Notify the delegate that the game result has been
                    // received.
                    self.delegate?.onGameResultReceived(SCGameResult(scores: self.scores, winner: self.winner))
                }
            case "part":
                // Add the found value to the current score object.
                self.score.values.append(self.foundChars)
            case "score":
                // Append the current score object to the array of scores.
                self.scores.append(self.score)
            case "state":
                self.gameStateCreated = true

                // Notify the delegate that the game state has been updated.
                self.delegate?.onGameStateUpdated(SCGameState(withGameState: self.gameState))
            default:
                break
        }
    }
}