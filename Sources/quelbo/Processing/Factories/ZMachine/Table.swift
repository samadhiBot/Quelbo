//
//  Table.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/7/22.
//

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

        var isPureTable: Bool {
            false
        }

        var isLengthTable: Bool {
            false
        }

        override func processTokens() throws {
            try super.processTokens()

            checkFlags()
        }

        override func process() throws -> Symbol {
            Symbol(
                "Table(\(symbols.codeValues(.commaSeparatedNoTrailingComma)))",
                type: .table,
                children: symbols
            )
        }
    }
}

extension Factories.Table {
    func checkFlags() {
        var isPureTable = isPureTable
        var isLengthTable = isLengthTable

        if let flags = symbols.first, flags.id == "<Flags>" {
            symbols.removeFirst()
            if flags.children.contains(where: { $0.id == "pure" }) {
                isPureTable = true
            }
            if flags.children.contains(where: { $0.id == "length" }) {
                isLengthTable = true
            }
        }

        if isPureTable {
            self.isMutable = false
            symbols.append(Symbol("isMutable: false"))
        }

        if isLengthTable {
            symbols.append(Symbol("hasLengthFlag: true"))
        }
    }
}
