//
//  Array+ext.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/8/22.
//

import Foundation

extension Array {
    var droppingFirst: Array {
        Array(dropFirst())
    }

    /// Safely shifts an `Element` from the front of an `Array`.
    ///
    /// - Returns: The first `Element` of the `Array`. Returns `nil` if the array is empty.
    public mutating func shift() -> Element? {
        guard !isEmpty else { return nil }
        return removeFirst()
    }
}

extension Array where Element == String {
    func values(_ displayOptions: CodeValuesDisplayOption...) -> String {
        values(displayOptions)
    }

    func values(_ displayOptions: [CodeValuesDisplayOption]) -> String {
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
        if lineBreaks == 0 && separator == "," {
            let code = joined(separator: separator)
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
        var values = joined(separator: separator)
        if indented {
            values = values.indented.rightTrimmed
        }
        if addBlock {
            values = "\n\(values)\(noTrailingComma ? "\n" : separator)"
        }
        return values
    }
}

extension Sequence where Iterator.Element: Hashable {
    var unique: [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
