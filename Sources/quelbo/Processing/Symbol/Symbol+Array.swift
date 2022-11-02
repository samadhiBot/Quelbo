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

    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Returns: <#description#>
    func find(_ id: String) -> Statement? {
        guard
            let found = first(where: { $0.id == id }),
            case .statement(let statement) = found
        else {
            return nil
        }
        return statement
    }

    func handles(_ displayOptions: CodeValuesDisplayOption...) -> String {
        map(\.handle).values(displayOptions)
    }

    var mostConfident: [Symbol] {
        reduce(into: []) { results, symbol in
            guard let sample = results.first?.type else {
                results.append(symbol)
                return
            }
            if symbol.type.confidence > sample.confidence {
                results = [symbol]
                return
            }
            if symbol.type > sample {
                results.insert(symbol, at: 0)
            } else {
                results.append(symbol)
            }
        }
    }

    var nonCommentSymbols: [Symbol] {
        compactMap { symbol in
            if case .statement(let statement) = symbol, statement.type == .comment {
                return nil
            }
            return symbol
        }
    }

    var returning: [Symbol] {
        let returningSymbols = returningExplicitly
        guard
            let implicitlyReturningLast = nonCommentSymbols.last,
            implicitlyReturningLast.returnHandling == .implicit,
            !returningSymbols.contains(implicitlyReturningLast)
        else {
            return returningSymbols
        }
        return returningSymbols + [implicitlyReturningLast]
    }

    var returningExplicitly: [Symbol] {
        reduce(into: []) { returnSymbols, symbol in
            if symbol.isReturnStatement {
                returnSymbols.append(symbol)
            }
            if case .statement(let statement) = symbol {
                returnSymbols.append(
                    contentsOf: statement.payload.symbols.returningExplicitly
                )
            }
        }
    }

    func returnType() -> TypeInfo? {
        let returningStatements = self.returningExplicitly
        if let explicitReturn = returningStatements.max(
            by: { $0.type.confidence < $1.type.confidence }
        ) {
            guard returningStatements.count > 1 else {
                return explicitReturn.type
            }
            if returningStatements.map(\.type.confidence).contains(.booleanFalse) {
                return explicitReturn.type.optional
            }
            return explicitReturn.type
        }
        if let lastSymbol = nonCommentSymbols.last, lastSymbol.isReturnable {
            return lastSymbol.type
        }
        return nil
    }

    /// Returns the ``Symbol`` array sorted by element ``Symbol/code`` for flag symbols, and by
    /// ``Symbol/description`` for all other symbols.
    var sorted: [Symbol] {
        sorted { $0.code < $1.code }
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