import Foundation

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
        let rootElem = "<root>".data(using: .utf8)!

        // Loop until the game is over.
        while !self.leaveGame {
            // Receive the message from the game server.
            var data = Data()
            self.socket.receive(into: &data)

            // Add the root element to the received XML document.
            data = rootElem + data

            // Parse the received XML document.
            let parser = XMLParser(data: data)
            parser.delegate = self
            _ = parser.parse()
        }
    }

    /// Exits the game with the given error message.
    ///
    /// - Parameter error: The error message to print into the standard output.
    private func exitGame(withError error: String) {
        if !error.isEmpty {
            print("ERROR: \(error)")
        }

        self.leaveGame = true
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "state" {
            self.gameStateCreated = true
            // Notify the delegate that the game state has been updated.
            self.delegate?.onGameStateUpdated(SCGameState(withGameState: self.gameState))
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
            case "data":
                // Get the class attribute.
                if let classS = attributeDict["class"] {
                    switch classS {
                        case "result":
                            // Leave the game.
                            self.delegate?.onGameEnded()
                            self.leaveGame = true
                            parser.abortParsing()
                        case "sc.framework.plugins.protocol.MoveRequest":
                            // Send the move returned by the game logic.
                            if var move = self.delegate?.onMoveRequested() {
                                var hints = ""
                                for hint in move.debugHints {
                                    hints += "<hint content=\"\(hint)\" />"
                                }
                                let mv = "<data class=\"move\" x=\"\(move.x)\" y=\"\(move.y)\" direction=\"\(move.direction)\">\(hints)</data>"
                                self.socket.send(message: "<room roomId=\"\(self.roomId!)\">\(mv)</room>")
                            } else {
                                self.exitGame(withError: "No move has been sent!")
                                parser.abortParsing()
                            }
                        case "welcomeMessage":
                            // Save the player color of this game client.
                            if let color = attributeDict["color"],
                               let playerColor = SCPlayerColor(rawValue: color.uppercased()) {
                                self.playerColor = playerColor
                            } else {
                                self.exitGame(withError: "The player color of the welcome message is missing or could not be parsed!")
                                parser.abortParsing()
                            }
                        default:
                            break
                    }
                } else {
                    self.exitGame(withError: "The class attribute of the data element is missing!")
                    parser.abortParsing()
                }
            case "field":
                if !self.gameStateCreated {
                    // Update the field on the board.
                    if let xS = attributeDict["x"],
                       let yS = attributeDict["y"],
                       let stateS = attributeDict["state"],
                       let x = Int(xS),
                       let y = Int(yS),
                       let state = SCFieldState(rawValue: stateS) {
                        self.gameState.setFieldState(x: x, y: y, state: state)
                    } else {
                        self.exitGame(withError: "A field could not be parsed!")
                        parser.abortParsing()
                    }
                }
            case "joined":
                // Save the room id of the game.
                if let roomId = attributeDict["roomId"] {
                    self.roomId = roomId
                } else {
                    self.exitGame(withError: "The room ID is missing!")
                    parser.abortParsing()
                }
            case "lastMove":
                // Perform the last move on the game state.
                if let xS = attributeDict["x"],
                   let yS = attributeDict["y"],
                   let dirS = attributeDict["direction"],
                   let x = Int(xS),
                   let y = Int(yS),
                   let dir = SCDirection(rawValue: dirS) {
                    if !self.gameState.performMove(move: SCMove(x: x, y: y, direction: dir)) {
                        self.exitGame(withError: "The last move could not be performed on the game state!")
                        parser.abortParsing()
                    }
                } else {
                    self.exitGame(withError: "The last move could not be parsed!")
                    parser.abortParsing()
                }
            case "left":
                // Leave the game.
                self.delegate?.onGameEnded()
                self.leaveGame = true
            case "state":
                // Create the initial game state and the game logic.
                if !self.gameStateCreated {
                    if let startPlayerColor = attributeDict["startPlayerColor"],
                       let startPlayer = SCPlayerColor(rawValue: startPlayerColor) {
                        self.gameState = SCGameState(startPlayer: startPlayer)

                        // TODO: Select the game logic based on the strategy.

                        self.delegate = SCGameLogic(player: self.playerColor)
                    } else {
                        self.exitGame(withError: "The initial game state could not be parsed!")
                        parser.abortParsing()
                    }
                }
            default:
                break
        }
    }
}