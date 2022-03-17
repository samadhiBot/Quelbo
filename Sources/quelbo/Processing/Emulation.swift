import Foundation

/// ZIL emulation namespace.
///
/// Contains types and methods that bridge the occasional gap between ZIL and Swift. These used in
/// the Swift translation of the game.
enum ZIL {}

// MARK: - ZIL Table

extension ZIL {
    /// The set
    enum TableElement {
        case atom(String)
        case bool(Bool)
        case decimal(Int)
        case table([TableElement])
    }

    struct Table {
        var elements: [TableElement]

        init(_ elements: TableElement...) {
            self.elements = elements
        }
    }
}

// MARK: - ZIL Methods

extension ZIL {
    /// Sets a variable to the specified value and returns the value.
    ///
    /// Emulates ZIL `SET`. Normal Swift assignment returns `Void`.
    ///
    /// - Parameters:
    ///   - variable: The variable to be assigned.
    ///   - value: The value to assign to `variable`.
    ///
    /// - Returns: The assigned `value`.
    static func set<T>(_ variable: inout T, to value: T) -> T {
        variable = value
        return value
    }
}

