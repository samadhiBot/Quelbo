//
//  Routine.swift
//  Quelbo
//
//  Created by Chris Sessions on 2/26/22.
//

import Foundation

/// `Routine` defines a program block with its own set of bindings.
///
/// Refer to the [ZILF Reference Guide](https://bit.ly/3vWs6Tt) for details.
struct Routine {
    var auxiliaries: [String] = []
    var tokens: [Token]

    init(_ tokens: [Token]) {
        self.tokens = tokens
    }
}

extension Routine {
    enum Err: Error {
        case missingName
        case missingTokens
    }

    mutating func process() throws -> Muddle.Definition {
        guard case .atom(let zilName) = tokens.shiftAtom() else {
            throw Err.missingName
        }
        let name = zilName.lowerCamelCase
        let parameters = try popTokens()
        var codeBlock = Code(tokens)

        return .init(
            name: name,
            code: """
                /// The `\(name)` (\(zilName)) routine.
                func \(name)(\(parameters.joined(separator: ", "))) {
                \(auxiliaryDefs)\(try codeBlock.process().indented(1))
                }
                """,
            dataType: nil,
            defType: .routine
        )
    }
}

private extension Routine {
    var auxiliaryDefs: String {
        guard !auxiliaries.isEmpty else { return "" }

        return auxiliaries
            .joined(separator: "\n")
            .indented(1)
            .appending("\n\n")
    }

    mutating func popTokens() throws -> [String] {
        guard case .list(let tokens) = tokens.shift() else {
            throw Err.missingTokens
        }
        var context: Variable.Parameter.Context = .normal
        return try tokens.compactMap { token in
            let value = try token.process()
            switch value {
            case #""AUX""#:
                context = .auxiliary
            case #""OPTIONAL""#:
                context = .optional
            default:
                let param = try Variable.Parameter(token, context)
                switch context {
                case .normal:
                    return param.definition
                case .auxiliary:
                    auxiliaries.append(param.definition)
                    return nil
                case .optional:
                    return param.definition
                }
            }
            return nil
        }
    }
}
