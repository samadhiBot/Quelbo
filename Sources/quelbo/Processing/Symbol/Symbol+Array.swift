//
//  Symbol+Array.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/2/22.
//

import Foundation

extension Array where Element == Symbol {
    /// Returns a formatted string containing the ``Symbol/code`` values for a ``Symbol`` array.
    ///
    /// - Parameter displayOptions: One or more ``Symbol/CodeValuesDisplayOption`` values that
    ///                             specify how to separate and display the code values.
    ///
    /// - Returns: A formatted string containing the code values contained in the symbol array.
    func codeValues(_ displayOptions: CodeValuesDisplayOption...) -> String {
        map(\.code).values(displayOptions)
    }

    func handles(_ displayOptions: CodeValuesDisplayOption...) -> String {
        map(\.handle).values(displayOptions)
    }

    func returnType() -> TypeInfo? {
        if let explicit = withReturnStatement.max(
            by: { $0.type.confidence < $1.type.confidence }
        ) {
            return explicit.type
        }
        guard
            let lastSymbol = nonCommentSymbols.last,
            lastSymbol.isReturnable
        else {
            return nil
        }
        return lastSymbol.type
    }

    /// Returns the ``Symbol`` array sorted by element ``Symbol/code`` for flag symbols, and by
    /// ``Symbol/description`` for all other symbols.
    var sorted: [Symbol] {
        sorted { $0.code < $1.code }
    }

    var withReturnStatement: [Symbol] {
        reduce(into: []) { returnSymbols, symbol in
            if symbol.isReturnStatement {
                returnSymbols.append(symbol)
            }
            if case .statement(let statement) = symbol {
                returnSymbols.append(contentsOf: statement.children.withReturnStatement)
            }
        }
    }
}

// MARK: - Array where Element == Symbol

/// Display options for use with the `codeValues` method.
enum CodeValuesDisplayOption {
    /// Values to be comma-separated with a line break after each value.
    case commaLineBreakSeparated

    /// Values to be comma-separated.
    case commaSeparated

    /// Values to be comma-separated.
    case commaSeparatedNoTrailingComma

    /// Values to be comma-separated with a double line break after each value.
    case doubleLineBreak

    /// The set of values to be indented.
    case indented

    /// Values to be separated by the specified string.
    case separator(String)

    /// Values to separated by a line break after each value.
    case singleLineBreak
}
