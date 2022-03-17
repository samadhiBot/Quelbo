//
//  Global+Table.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/10/22.
//

import Foundation

extension Global {
    /// `Table` defines an array-like structure containing the specified mixed-type values.
    ///
    /// Refer to the [ZILF Reference Guide](https://bit.ly/3vWceQH) for details.
    struct Table {
        var isMutable: Bool
        let nestLevel: Int
        var values = [String]()

        init(
            _ tableTokens: [Token],
            nestLevel: Int = 0,
            isMutable: Bool = true
        ) throws {
            self.isMutable = isMutable
            self.nestLevel = nestLevel
            var tokens = tableTokens
            while !tokens.isEmpty {
                let token = tokens.shift()
                switch token! {
                case .atom(let value):
                    values.append(".atom(\"\(value)\")")
                case .bool(let value):
                    values.append(".bool(\(value))")
                case .commented(_):
                    continue
                case .decimal(let value):
                    values.append(".decimal(\(value))")
                case .form(var tokens):
                    guard let type = try tokens.shiftAtom()?.process() else {
                        throw Err.missingType
                    }
                    switch type {
                    case "ltable", "table":
                        let nestedTable = try Table(tokens, nestLevel: nestLevel + 1)
                        values.append(nestedTable.definition)
                    default:
                        fatalError("❌ \(tokens)")
                    }
                case .list(let tokens):
                    if tokens == [.atom("PURE")] {
                        self.isMutable = false
                        continue
                    }
                    values.append(".list(\(tokens))")
                case .quoted(let token):
                    values.append(".string(\"\(token)\")")
                case .string(let value):
                    values.append(".string(\(value.quoted(nestLevel)))")
                }
            }
        }
    }
}

extension Global.Table {
    enum Err: Error {
        case missingType
    }

    var declare: String {
        isMutable ? "var" : "let"
    }

    var definition: String {
        [
            "\(nestLevel == 0 ? "ZIL.Table" : ".table")(",
            "\(values.joined(separator: ",\n")),".indented(1),
            ")"
        ].joined(separator: "\n")
    }
}
