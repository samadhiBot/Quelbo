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
class Game {
    /// An array of `Definition` values representing the game's definitions.
    private(set) var definitions: [Definition] = []

    /// An array of ``Symbol`` symbols processed from the `tokens`.
    private(set) var symbols: [Symbol] = []

    /// An array of ``Token`` values parsed from the raw Zil code.
    private(set) var tokens: [Token] = []

    /// The ZMachine version to emulate during processing.
    private(set) var zMachineVersion: Game.ZMachineVersion = .z3

    /// A shared instance of the ``Game`` representation.
    static var shared = Game()

    /// Parses Zil source code from a file at the specified path.
    /// - Parameter path: The path to the Zil source code file.
    func parseZilSource(at path: String) throws {
        let parser = Game.Parser()
        try parser.parseZilSource(at: path)
        tokens = parser.parsedTokens
    }

    /// Processes the parsed tokens and converts them to Swift.
    /// - Parameters:
    ///   - target: The target location for the output.
    ///   - printSymbolsOnFail: A flag that indicates whether symbols should be printed on failure.
    ///   - printUnprocessedTokensOnFail: A flag that indicates whether unprocessed tokens should
    ///                                   be printed on failure.
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
    /// Commits a `Symbol` to the game.
    /// - Parameter symbol: The `Symbol` to commit.
    static func commit(_ symbol: Symbol) throws {
        switch symbol {
        case .definition(let definition):
            if let found = findDefinition(definition.id) {
                guard definition == found else {
                    throw GameError.commitDefinitionConflict(definition.id)
                }
                return
            }
            if definition.isCommittable {
                shared.definitions.append(definition)
            }

        case .instance, .literal:
            break

        case .statement(let statement):
            if statement.isCommittable,
               let id = statement.id,
               let category = statement.category
            {
                if let existing = try? find(id, in: [category]) {
                    try existing.assertHasType(statement.type)
                } else {
                    shared.symbols.append(symbol)
                }
            }

            try commit(statement.payload.symbols)
        }
    }

    /// Commits an array of `Symbol`s to the game.
    /// - Parameter symbols: The array of `Symbol`s to commit.
    static func commit(_ symbols: [Symbol]) throws {
        for symbol in symbols {
            try commit(symbol)
        }
    }

    /// Finds a statement in the given categories based on its ID.
    ///
    /// Throws an error if the statement is not found or if multiple statements with the same ID
    /// are found.
    ///
    /// - Parameters:
    ///   - id: The ID of the statement to be found.
    ///   - categories: An array of categories to search in (default is an empty array).
    ///
    /// - Throws: `GameError.statementNotFound` if the statement is not found, or
    ///           `GameError.multipleStatementsFound` if multiple statements with
    ///           the same ID are found.
    ///
    /// - Returns: The found statement, or nil if not found.
    static func find(
        _ id: String,
        in categories: [Category] = []
    ) throws -> Statement? {
        let symbols = shared.symbols.filter { $0.id == id }
        switch symbols.count {
        case 0:
            return nil
        case 1:
            guard case .statement(let statement) = symbols[0] else {
                throw GameError.statementNotFound(id)
            }
            if categories.isEmpty { return statement }
            guard
                let category = statement.category,
                categories.contains(category)
            else {
                throw GameError.statementNotFound(id, in: categories)
            }
            return statement
        default:
            guard !categories.isEmpty else {
                throw GameError.multipleStatementsFound(id)
            }
            for category in categories {
                for symbol in symbols {
                    guard
                        case .statement(let statement) = symbol,
                        category == statement.category
                    else {
                        continue
                    }
                    return statement
                }
            }
            throw GameError.statementNotFound(id, in: categories)
        }
    }

    /// Finds a definition with the given ID.
    ///
    /// - Parameter id: The ID of the definition to be found.
    ///
    /// - Returns: The found definition, or nil if not found.
    static func findDefinition(_ id: String) -> Definition? {
        guard let found = shared.definitions.first(where: { $0.id == id }) else {
            return nil
        }
        return found
    }

    /// Finds a factory with the given ID and optional type.
    ///
    /// - Parameters:
    ///   - id: The ID of the factory to be found.
    ///   - type: The factory type to match (default is nil).
    ///
    /// - Returns: The found factory of the specified type, or nil if not found.
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

    /// Finds an instance with the given ID.
    ///
    /// - Parameter id: The ID of the instance to be found.
    ///
    /// - Returns: The found instance, or nil if not found.
    static func findInstance(_ id: String) -> Instance? {
        guard let global = try? find(id) else { return nil }
        return Instance(global)
    }

    /// Finds a routine with the given ID.
    ///
    /// - Parameter id: The ID of the routine to be found.
    ///
    /// - Returns: The found routine, or nil if not found.
    static func findRoutine(_ id: String) -> Statement? {
        if let routine = Game.routines.find(id) {
            return routine
        }
        guard
            let syntax = Game.syntax.find(id),
            let actionID = syntax.payload.symbols.last?.id,
            let actionRoutine = Game.routines.find(actionID)
        else {
            return nil
        }
        return actionRoutine
    }

    /// Resets the game state with the given definitions, symbols, tokens, and Z-Machine version.
    ///
    /// - Parameters:
    ///   - definitions: An array of definitions to use (default is an empty array).
    ///   - symbols: An array of symbols to use (default is an empty array).
    ///   - tokens: An array of tokens to use (default is an empty array).
    ///   - zMachineVersion: The Z-Machine version to use (default is .z3).
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
    /// Sets the ZMachine version for the game.
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

/// <#Description#>
enum GameError: Swift.Error {
    /// Indicates a conflict when committing a definition.
    case commitDefinitionConflict(String)

    /// Indicates an error in processing tokens.
    case failedToProcessTokens([String])

    /// Indicates a global symbol was not found with the given ID and ZIL.
    case globalNotFound(id: String, zil: String)

    /// Indicates an invalid Z-Machine version for the given tokens.
    case invalidZMachineVersion([Token])

    /// Indicates multiple statements were found with the given ID.
    case multipleStatementsFound(String)

    /// Indicates a statement was not found with the given ID.
    case statementNotFound(String)

    /// Indicates a statement was not found with the given ID and categories.
    case statementNotFound(String, in: [Category])

    /// Indicates an unknown root evaluation for the given token.
    case unknownRootEvaluation(Token)

    /// Indicates an unknown directive for the given tokens.
    case unknownDirective([Token])
}
