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
        var blockProcessor: BlockProcessor!

        override func processTokens() throws {
            var callerParams = tokens
            let zilName = try findName(in: &callerParams).lowerCamelCase

            guard let rawDefinition = Game.findDefinition(zilName) else {
                throw Error.definitionNotFound(zilName)
            }
            var defTokens = rawDefinition.tokens

            var activation: String?
            if case .atom(let act) = defTokens.first {
                activation = act
                defTokens.removeFirst()
            }

            guard case .list(var defParams) = defTokens.shift() else {
                throw Error.definitionParametersNotFound(defTokens)
            }

            for substitution in substitutions(from: defParams, to: callerParams) {
                defParams = try defParams.deepReplacing(substitution.0, with: substitution.1)
                defTokens = try defTokens.deepReplacing(substitution.0, with: substitution.1)
            }

            defTokens.insert(.list(defParams), at: 0)

            if let activation = activation {
                defTokens.insert(.atom(activation), at: 0)
            }

            self.blockProcessor = try BlockProcessor(
                defTokens,
                with: &localVariables
            )
            blockProcessor.assert(
                activation: activation
            )
        }

        @discardableResult
        override func process() throws -> Symbol {
            let pro = blockProcessor!

            return .statement(
                code: { _ in
                    """
                    {
                    \(pro.auxiliaryDefs.indented)\
                    \(pro.code.indented)
                    }()
                    """
                },
                type: pro.returnType() ?? .unknown
            )
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
        _ originalToken: Token,
        with replacementToken: Token
    ) throws -> [Token] {
        let original = originalToken.value
        return try evaluated.map { (token: Token) -> Token in
            switch token {
            case originalToken:
                return replacementToken
            case .atom(let string):
                return string == original ? replacementToken : token
            case .form(let tokens):
                return try .form(tokens.deepReplacing(originalToken, with: replacementToken))
            case .global(let string):
                return string == original ? replacementToken : token
            case .list(let tokens):
                return try .list(tokens.deepReplacing(originalToken, with: replacementToken))
            case .local(let string):
                return string == original ? replacementToken : token
            case .property(let string):
                return string == original ? replacementToken : token
            case .vector(let tokens):
                return try .vector(tokens.deepReplacing(originalToken, with: replacementToken))
            default:
                return token
            }
        }
    }
}
