//
//  Zil+Condition.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/12/22.
//

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

    mutating func process() throws -> String {
        try tokens.compactMap { (list: Token) -> Conditional? in
            guard case .list(var listTokens) = list else {
                if case .commented = list {
                    return nil // ignore comments
                }
                throw Err.unexpectedTokenInList("\(tokens)")
            }
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
                    return action == "return()" ? "break" : action
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
                return """
                    if \(try conditional.predicate.process()) {
                    \(actions)
                    }
                    """
            }
        }.joined(separator: " else ")
    }
}
