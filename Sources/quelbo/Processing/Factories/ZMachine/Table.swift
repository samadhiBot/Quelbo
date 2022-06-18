//
//  Table.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/7/22.
//

import Fizmo
import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [TABLE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2kz067v)
    /// function.
    class Table: ZMachineFactory {
        override class var zilNames: [String] {
            ["TABLE"]
        }

        override class var parameters: Parameters {
            .twoOrMore(.zilElement)
        }

        override class var returnType: Symbol.DataType {
            .table
        }

        var presetFlags: [Fizmo.Table.Flag] {
            []
        }

        var flags: Swift.Set<Fizmo.Table.Flag> = []

        override func processTokens() throws {
            try super.processTokens()

            presetFlags.forEach { flags.insert($0) }
            checkFlags()
        }

        override func process() throws -> Symbol {
            processFlags()

            return Symbol(
                "Table(\(symbols.codeValues(.commaSeparatedNoTrailingComma)))",
                type: .table,
                children: symbols
            )
        }
    }
}

extension Factories.Table {
    func checkFlags() {
        guard
            let symbol = symbols.first,
            symbol.containsTableFlags
        else {
            return
        }
        symbols.removeFirst()

        let fizmoFlags = symbol.children.compactMap {
            Fizmo.Table.Flag(rawValue: $0.code)
        }
        fizmoFlags.forEach { flags.insert($0) }
    }

    func processFlags() {
        guard !flags.isEmpty else {
            return
        }
        let flagValues = flags
            .map({ ".\($0)" })
            .sorted()
            .joined(separator: ", ")
        symbols.append(Symbol(
            "flags: [\(flagValues)]"
        ))
        if flags.contains(.pure) {
            isMutable = false
        }
    }
}
