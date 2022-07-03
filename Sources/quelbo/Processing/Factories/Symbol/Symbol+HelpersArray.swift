//
//  Symbol+HelpersArray.swift
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
    func codeValues(_ displayOptions: Symbol.CodeValuesDisplayOption...) -> String {
        var addBlock = false
        var indented = false
        var lineBreaks = 0
        var noTrailingComma = false
        var separator = ""

        displayOptions.forEach { option in
            switch option {
            case .commaLineBreakSeparated:
                indented = true
                lineBreaks = 1
                separator = ","
            case .commaSeparated:
                separator = ","
            case .commaSeparatedNoTrailingComma:
                noTrailingComma = true
                separator = ","
            case .doubleLineBreak:
                lineBreaks = 2
            case .indented:
                indented = true
            case .separator(let string):
                separator = string.rightTrimmed
            case .singleLineBreak:
                lineBreaks = 1
            }
        }
        let codeValues = map(\.code)
        if lineBreaks == 0 && separator == "," {
            let code = codeValues.joined(separator: separator)
            if code.count > 20 || code.contains("\n") {
                addBlock = true
                lineBreaks = 1
                indented = true
            }
        }
        if lineBreaks == 0 {
            separator.append(" ")
        }
        for _ in 0..<lineBreaks {
            separator.append("\n")
        }
        var values = codeValues.joined(separator: separator)
        if indented {
            values = values.indented.rightTrimmed
        }
        if addBlock {
            values = "\n\(values)\(noTrailingComma ? "\n" : separator)"
        }
        return values
    }

    /// <#Description#>
    var deepActivation: String? {
        for symbol in self {
            switch symbol.controlflow {
            case .again(activation: let activation):
                return activation
            case .block, .return, .returnValue:
                continue
            case .none:
                if let childActivation = symbol.children.deepActivation {
                    return childActivation
                }
            }
        }
        return nil
    }

    /// Deep-searches a ``Symbol`` array for a `"paramDeclarations"` metadata declaration, and
    /// returns its value if one is found.
    var deepParamDeclarations: String? {
        for symbol in self {
            for metaData in symbol.meta {
                if case .paramDeclarations(let params) = metaData {
                    return params
                }
            }
            if let paramDeclarations = symbol.children.deepParamDeclarations {
                return paramDeclarations
            }
        }
        return nil
    }

    /*
     💡 Can we lose `blockType` at factory level and just look within each block for `AGAIN` / `RETURN`?
     */
    /// Deep-searches a ``Symbol`` array for a <#Description#>
    var deepRepeating: Bool? {
        for symbol in self {
            switch symbol.controlflow {
            case .again:
                return true
            case .block, .return, .returnValue:
                continue
            case .none:
                if let childRepeating = symbol.children.deepRepeating {
                    return childRepeating
                }
            }
        }
        return nil
    }

    var deepReplaceEmptyReturnValues: [Symbol] {
        map {
            $0.with(
                code: $0.code.replacingOccurrences(of: "return false", with: "return nil"),
                children: $0.children.deepReplaceEmptyReturnValues
            )
        }
    }

    /// Deep-searches a ``Symbol`` array for explicit `return` statements with return values, and
    /// returns their symbol representations.
    var deepReturnTypes: [Symbol] {
        reduce(into: [Symbol]()) { partial, symbol in
            partial.append(contentsOf: symbol.children.deepReturnTypes)
            if let _ = symbol.returnValueType {
                partial.append(symbol)
            }
//            partial.sort { $0.typeCertainty > $1.typeCertainty }
//            let sorted = partial.sorted(by: { $0.typeCertainty > $1.typeCertainty })
//            guard let maxCertainty = sorted.first?.typeCertainty else {
//                return
//            }
//            partial = sorted.filter { $0.typeCertainty >= maxCertainty }
        }
    }

    /// Searches the array to find a ``Symbol`` with the specified `id`.
    ///
    /// The recursive search inspects each `Symbol` and each symbol's `children`, until it finds a
    /// match, which it returns.
    ///
    /// - Parameter id: A unique `Symbol` identifier.
    ///
    /// - Returns: A `Symbol` with the specified `id`, if one exists within the array.
    func find(id symbolID: Symbol.Identifier?) -> Symbol? {
        guard let symbolID = symbolID else { return nil }

        for symbol in self {
            if symbolID == symbol.id {
                return symbol
            } else if let childSymbol = symbol.children.find(id: symbolID) {
                return childSymbol
            }
        }
        return nil
    }

    /// <#Description#>
    ///
    /// - Returns: <#description#>
    func findByTypeCertainty() -> Symbol? {
        guard count > 1 else { return first }

        var symbols = sorted { $0.typeCertainty > $1.typeCertainty }
        while let subject = symbols.shift() {
            if subject.typeCertainty > symbols.first?.typeCertainty ?? .unknown {
                return subject
            }
            if subject.type != symbols.first?.type {
                return nil
            }
        }
        return nil
    }

    /// Returns the ``Symbol`` array with quotes applied to the code values of any elements with
    /// type ``Symbol/DataType/string``.
    var quoted: [Symbol] {
        map { symbol in
            guard symbol.type == .string else {
                return symbol
            }
            return symbol.with(code: symbol.code.quoted)
        }
    }

    /// Returns the ``Symbol`` array sorted by element ``Symbol/code`` for flag symbols, and by
    /// ``Symbol/description`` for all other symbols.
    var sorted: [Symbol] {
        sorted {
            if $0.category == .flags {
                return $0.code < $1.code
            } else {
                return $0.description < $1.description
            }
        }
    }
}

// MARK: - Array where Element == Symbol

extension Symbol {
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
}
