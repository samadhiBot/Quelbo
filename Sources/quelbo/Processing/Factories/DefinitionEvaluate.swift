//
//  DefinitionEvaluate.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for calls to functions and routines defined in a game.
    ///
    class DefinitionEvaluate: Factory {
        /// <#Description#>
        var evaluatedMacro: Symbol!

        override func processTokens() throws {
            var callerParams = tokens
            let zilName = try findName(in: &callerParams)

            guard let rawDefinition = Game.findDefinition(zilName.lowerCamelCase) else {
                throw Error.definitionNotFound(zilName)
            }
            var definitionTokens = rawDefinition.tokens

            var activation: String?
            if case .atom(let act) = definitionTokens.first {
                activation = act
                definitionTokens.removeFirst()
            }

            guard case .list(let definitionParams) = definitionTokens.first else {
                throw Error.definitionParametersNotFound(definitionTokens)
            }

            for substitution in substitutions(from: definitionParams, to: callerParams) {
                definitionTokens = definitionTokens.deepReplacing(
                    from: substitution.0,
                    to: substitution.1
                )
            }

            if let activation {
                definitionTokens.insert(.atom(activation), at: 0)
            }
            definitionTokens.insert(.atom(zilName), at: 0)

            let routine = try Factories.Routine(
                definitionTokens,
                with: &localVariables
            )
            routine.blockProcessor.assert(
                returnHandling: .implicit
            )
            try Game.commit(
                try routine.process()
            )

            let evaluated = try Factories.RoutineCall(
                [.atom(zilName)] + callerParams,
                with: &localVariables
            )

            self.evaluatedMacro = try evaluated.process()
        }

        override func process() throws -> Symbol {
            evaluatedMacro
        }
    }
}

extension Factories.DefinitionEvaluate {
    func substitutions(
        from fromParams: [Token],
        to toParams: [Token]
    ) -> [(Token, Token)] {
        var subs: [(Token, Token)] = []
        var toParams = toParams

        for token in fromParams {
            switch token {
            case .atom:
                guard let substitution = toParams.shift() else { continue }
                subs.append((token, substitution))
            case .list(let listTokens):
                guard
                    listTokens.count == 2,
                    let substitution = toParams.shift()
                else { continue }
                subs.append((token, .list([listTokens[0], substitution])))
            case .quote(let token):
                subs.append(contentsOf: substitutions(from: [token], to: toParams))
            case .string("ARGS"),
                 .string("AUX"),
                 .string("EXTRA"),
                 .string("OPT"),
                 .string("OPTIONAL"): continue
            default:
                continue
            }
        }
        return subs
    }
}

// MARK: - Errors

extension Factories.DefinitionEvaluate {
    enum Error: Swift.Error {
        case definitionNotFound(String)
        case definitionParametersNotFound([Token])
        case missingDefinitionIdentifier(Symbol)
    }
}

// MARK: - Token Array Conformances

extension Array where Element == Token {
    /// <#Description#>
    /// - Parameters:
    ///   - originalToken: <#originalToken description#>
    ///   - replacementToken: <#replacementToken description#>
    /// - Returns: <#description#>
    func deepReplacing(
        from originalToken: Token,
        to replacementToken: Token
    ) -> [Token] {
        let original = originalToken.value
        return evaluated.map { (token: Token) -> Token in
            switch token {
            case originalToken:
                return replacementToken
            case .atom(let string):
                return string == original ? replacementToken : token
            case .form(let tokens):
                return .form(tokens.deepReplacing(from: originalToken, to: replacementToken))
            case .list(let tokens):
                return .list(tokens.deepReplacing(from: originalToken, to: replacementToken))
            case .local(let string):
                return string == original ? replacementToken : token
            case .property(let string):
                return string == original ? replacementToken : token
            case .vector(let tokens):
                return .vector(tokens.deepReplacing(from: originalToken, to: replacementToken))
            default:
                return token
            }
        }
    }
}
