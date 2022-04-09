/*
//  Zil+Condition.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/12/22.
//

import Foundation
import Fizmo

extension Zil {
    struct Condition {
        var tokens: [Token]

        init(_ tokens: [Token]) {
            self.tokens = tokens
        }
    }
}

extension Zil.Condition {
    enum Err: Error {
        case missingPredicate(String)
        case unexpectedTokenInList(String)
    }

    private struct Conditional {
        let predicate: Token
        let actions: [Token]
    }

    mutating func process() throws -> Symbol {
        var macroQuoted = false
        var symbols: [Symbol] = []

        let condition = try tokens.compactMap { (list: Token) -> Conditional? in
            var listTokens: [Token] = []

            switch list {
            case .atom(let value):
                if value == "%" || value == "'" {
                    macroQuoted = true
                    return nil // skip over macro and quoted annotations
                }
            case .commented:
                return nil // ignore comments
            case .form(var tokens):
                guard macroQuoted, case .atom("COND") = tokens.shiftAtom() else { break }
                listTokens = tokens
            case .list(let tokens):
                listTokens = tokens
            default:
                break
            }
            if listTokens.isEmpty {
                throw Err.unexpectedTokenInList("\(list) ❌\(tokens)")
            }
            macroQuoted = false
            guard let predicate = listTokens.shift() else {
                throw Err.missingPredicate("\(tokens)")
            }
            return Conditional(
                predicate: predicate,
                actions: listTokens
            )
        }.map { conditional in
            let actions = try conditional.actions
                .map {
                    let action = try $0.process()
                    symbols.append(action)
                    return action.description == "return()" ? "break" : action.description
                }
                .joined(separator: "\n")
                .indented()
            if case .atom("T") = conditional.predicate {
                return """
                    {
                    \(actions)
                    }
                    """
            } else {
                let predicate = try conditional.predicate.process()
                symbols.append(predicate)
                return """
                    if \(predicate) {
                    \(actions)
                    }
                    """
            }
        }.joined(separator: " else ")

        let returnType = symbols.last?.type ?? .void
        let conditionalCode = returnType == .void ? condition :
            """
            {
            \(condition.indented())
            }()
            """
        return Symbol(
            code: conditionalCode,
            name: "condition()",
            type: returnType,
            children: symbols
        )
    }
}
*/
