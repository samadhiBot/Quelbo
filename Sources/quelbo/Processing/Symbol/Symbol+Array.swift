//
//  Symbol+Array.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/2/22.
//

import Foundation

extension Array where Element == Symbol {
    var allValuesHaveSameType: Bool {
        map(\.type.dataType).unique.count <= 1
    }

    /// Returns a formatted string containing the ``Symbol/code`` values for a ``Symbol`` array.
    ///
    /// - Parameter displayOptions: One or more ``Symbol/CodeValuesDisplayOption`` values that
    ///                             specify how to separate and display the code values.
    ///
    /// - Returns: A formatted string containing the code values contained in the symbol array.
    func codeValues(_ displayOptions: CodeValuesDisplayOption...) -> String {
        allValuesHaveSameType ? map(\.code).values(displayOptions)
                              : map(\.codeMultiType).values(displayOptions)
    }

    func codeMultiTypeValues(_ displayOptions: CodeValuesDisplayOption...) -> String {
        map(\.codeMultiType).values(displayOptions)
    }

    var evaluationErrors: [Swift.Error] {
        compactMap { symbol in
            guard
                case .definition(let definition) = symbol,
                let evaluationError = definition.evaluationError
            else { return nil }
            return evaluationError
        }
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
        allValuesHaveSameType ? map(\.handle).values(displayOptions)
                              : map(\.handleMultiType).values(displayOptions)
    }

    var nonCommentSymbols: [Symbol] {
        filter { $0.type != .comment }
    }

    var explicitlyReturningSymbols: [Symbol] {
        reduce(into: []) { returnSymbols, symbol in
            if symbol.returnHandling == .forced {
                returnSymbols.append(symbol)
            }
            if symbol.returnHandling.isPassthrough, let payload = symbol.payload {
                returnSymbols.append(
                    contentsOf: payload.symbols.explicitlyReturningSymbols
                )
            }
        }
    }

    var implicitlyReturningLastSymbol: Symbol? {
        guard
            let lastSymbol = nonCommentSymbols.last,
            lastSymbol.returnHandling > .suppressed,
            lastSymbol.type.hasReturnValue
        else {
            return nil
        }
        return lastSymbol
    }

    var returningSymbols: [Symbol] {
        let returningSymbols = explicitlyReturningSymbols

        if !returningSymbols.isEmpty  {
            return returningSymbols
        }

        guard
            let lastSymbol = implicitlyReturningLastSymbol,
            lastSymbol.returnHandling > .implicit
        else {
            return []
        }
        return [lastSymbol]
    }

    var returnType: TypeInfo? {
        let alphas = withMaxConfidence
        let uniqueTypes = alphas.map(\.type.dataType).unique
        switch uniqueTypes.count {
        case 1:
            return alphas[0].type
        case 2:
            if let optionalType = alphas.sharedOptionalType {
                return optionalType
            }
            return nil
        default:
            return nil
        }
    }

    var sharedOptionalType: TypeInfo? {
        guard map(\.type).unique.count == 2 else {
            return nil
        }
        if map(\.type.confidence).contains(.booleanFalse),
           let other = first(where: { $0.type.confidence > .booleanFalse })
        {
            return other.type.optional
        }
        if map(\.type.confidence).contains(.integerZero),
           let other = first(where: { $0.type.confidence > .integerZero })
        {
            return other.type.optional
        }
        return nil
    }

    /// Returns the ``Symbol`` array sorted by element ``Symbol/code`` for flag symbols, and by
    /// ``Symbol/description`` for all other symbols.
    var sorted: [Symbol] {
        sorted { $0.code < $1.code }
    }

    var splitByReturnHandling: ([Symbol], [Symbol]) {
        let explicitlyReturning = withMaxReturnHandling
        return (
            explicitlyReturning,
            filter { !explicitlyReturning.contains($0) }
        )
    }

    var withNoTypeConfidence: [Symbol] {
        filter { $0.type.confidence == .none }
    }

    var withMaxConfidence: [Symbol] {
        nonCommentSymbols.reduce(into: []) { results, symbol in
//            guard ![.comment, .unknown].contains(symbol.type) else {
//                return
//            }
            guard let sample = results.first?.type else {
                results = [symbol]
                return
            }
            if symbol.type.confidence > sample.confidence {
                results = [symbol]
            } else if symbol.type > sample {
                results.insert(symbol, at: 0)
            } else {
                results.append(symbol)
            }
        }
    }

    var withMaxReturnHandling: [Symbol] {
        reduce(into: []) { results, symbol in
            guard let maxHandling = results.first?.returnHandling else {
                results = [symbol]
                return
            }
            if symbol.returnHandling > maxHandling {
                results = [symbol]
            } else if symbol.returnHandling == maxHandling {
                results.append(symbol)
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
