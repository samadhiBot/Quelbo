//
//  Game.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Fizmo
import Foundation
import Parsing
import os.log

/// A container for a Zil to Swift game translation.
///
class Game {
    /// <#Description#>
    private(set) var definitions: [Definition] = []

    /// An array of ``Symbol`` symbols processed from the `tokens`.
    private(set) var symbols: [Symbol] = []

    /// An array of ``Token`` values parsed from the raw Zil code.
    private(set) var tokens: [Token] = []

    /// The ZMachine version to emulate during processing.
    private(set) var zMachineVersion: Game.ZMachineVersion = .z3

    /// A shared instance of the ``Game`` representation.
    static var shared = Game()

    /// <#Description#>
    /// - Parameter path: <#path description#>
    func parseZilSource(at path: String) throws {
        let parser = Game.Parser()
        try parser.parseZilSource(at: path)
        tokens = parser.parsedTokens
    }

    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - printSymbolsOnFail: <#printSymbolsOnFail description#>
    func processTokens(
        to target: String? = nil,
        printSymbolsOnFail: Bool,
        printUnprocessedTokensOnFail: Bool
    ) throws {
        let processor = Game.Processor(
            tokens: tokens,
            target: target,
            printSymbolsOnFail: printSymbolsOnFail,
            printUnprocessedTokensOnFail: printUnprocessedTokensOnFail
        )
        try processor.processTokens()
    }
}

// MARK: - Game symbol storage

extension Game {
    /// <#Description#>
    /// - Parameter symbol: <#symbol description#>
    static func commit(_ symbol: Symbol) throws {
        try commit([symbol])
    }

    /// <#Description#>
    /// - Parameter symbols: <#symbols description#>
    static func commit(_ symbols: [Symbol]) throws {
        for symbol in symbols {
            switch symbol {
            case .definition(let definition):
                if let found = findDefinition(definition.id) {
                    guard definition == found else {
                        throw GameError.commitDefinitionConflict(definition.id)
                    }
                    continue
                }
                shared.definitions.append(definition)

            case .instance, .literal:
                break

            case .statement(let statement):
                if statement.isCommittable, let id = statement.id {
                    guard shared.symbols.find(id) == nil else {
                        continue
                    }
                    shared.symbols.append(symbol)
                }
                try commit(statement.payload.symbols)
            }
        }
    }

    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Returns: <#description#>
    static func findDefinition(_ id: String) -> Definition? {
        guard let found = shared.definitions.first(where: { $0.id == id }) else {
            return nil
        }
        return found
    }

    /// <#Description#>
    /// - Parameters:
    ///   - id: <#id description#>
    ///   - root: <#root description#>
    /// - Returns: <#description#>
    static func findFactory(
        _ id: String,
        type: Factories.FactoryType? = nil
    ) -> Factory.Type? {
        let found = factories.filter { $0.zilNames.contains(id) }
        switch found.count {
        case 0: return nil
        case 1: return found[0]
        default: return found.first { type == $0.factoryType }
        }
    }

    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Returns: <#description#>
    static func findGlobal(_ id: String) -> Instance? {
        guard let global = shared.symbols.find(id) else { return nil }
        return Instance(global)
    }

    /// <#Description#>
    static func reset(
        definitions: [Definition] = [],
        symbols: [Symbol] = [],
        tokens: [Token] = [],
        zMachineVersion: Game.ZMachineVersion = .z3
    ) {
        shared.definitions = definitions
        shared.symbols = Game.reservedGlobals + symbols
        shared.tokens = tokens
        shared.zMachineVersion = zMachineVersion
    }
}

// MARK: - Game factories

extension Game {
    /// ``Symbol`` factories for translating ZIL Object properties.
    static let factories = _Runtime
        .subclasses(of: Factory.self)
        .map { $0 as! Factory.Type }
}

// MARK: - setZMachineVersion

extension Game {
    /// <#Description#>
    func setZMachineVersion() throws {
        for token in tokens {
            guard
                case .form(var formTokens) = token,
                case .atom("VERSION") = formTokens.shift()
            else {
                continue
            }
            self.zMachineVersion = try Game.ZMachineVersion(tokens: formTokens)
            break
        }

        Game.Print.heading(
            """

            􀀷  Z-machine version
            """,
            zMachineVersion.rawValue
        )
    }
}

// MARK: - GameError

enum GameError: Swift.Error {
    case commitDefinitionConflict(String)
    case commitStatementConflict(String)
    case factoryNotFound(String)
    case failedToProcessTokens([String])
    case globalNotFound(String)
    case invalidCommitType(Symbol)
    case invalidZMachineVersion([Token])
    case unexpectedAtRootLevel(Token)
    case unknownDirective([Token])
    case unknownOperation(String)
    case variableUpsertConflict(old: Statement, new: Statement)
}
