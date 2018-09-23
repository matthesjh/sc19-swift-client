/// The state of a field.
enum SCFieldState: String, CustomStringConvertible {
    /// The field is covered with a red fish.
    case red = "RED"
    /// The field is covered with a blue fish.
    case blue = "BLUE"
    /// The field is covered with an octopus.
    case obstructed = "OBSTRUCTED"
    /// The field is empty.
    case empty = "EMPTY"

    var description: String {
        return self.rawValue
    }
}