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

    /// <#Description#>
    private(set) var globalVariables: [Variable] = Game.reservedGlobals

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
        with printSymbolsOnFail: Bool = false
    ) throws {
        let processor = Game.Processor(
            tokens: tokens,
            target: target,
            printSymbolsOnFail: printSymbolsOnFail
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
                shared.definitions.append(definition)

            case .instance, .literal:
                break

            case .statement(let statement):
                if statement.isCommittable {
                    shared.symbols.append(symbol)
                }
                try commit(statement.children)

            case .variable(let variable):
                try shared.globalVariables.commit(variable)
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
    static func findGlobal(_ id: String) -> Variable? {
        shared.globalVariables.first { $0.id == id }
    }

    /// <#Description#>
    static func reset(
        definitions: [Definition] = [],
        globalVariables: [Variable] = Game.reservedGlobals,
        symbols: [Symbol] = [],
        tokens: [Token] = [],
        zMachineVersion: Game.ZMachineVersion = .z3
    ) {
        shared.definitions = definitions
        shared.globalVariables = globalVariables
        shared.symbols = symbols
        shared.tokens = tokens
        shared.zMachineVersion = zMachineVersion
    }
}

extension Array where Element == Symbol {
    func find(_ id: String) -> Statement? {
        guard
            let found = first(where: { $0.id == id }),
            case .statement(let statement) = found
        else {
            return nil
        }
        return statement
    }
}

// MARK: - Game factories

extension Game {
    /// ``Symbol`` factories for translating ZIL Object properties.
    static let factories = _Runtime
        .subclasses(of: Factory.self)
        .map { $0 as! Factory.Type }

    static func makeFactory(
        zil: String,
        tokens: [Token],
        with localVariables: inout [Variable],
        type factoryType: Factories.FactoryType? = nil,
        mode factoryMode: Factory.FactoryMode = .process
    ) throws -> Factory {
        if let factory = Game.findFactory(zil, type: factoryType) {
            var factoryTokens: [Token] {
                switch tokens.first {
                case .atom(zil): return tokens.droppingFirst
                case .decimal: return tokens.droppingFirst
                case .global(zil): return tokens.droppingFirst
                default: return tokens
                }
            }
            return try factory.init(
                factoryTokens,
                with: &localVariables,
                mode: factoryMode
            )
        }

        if Game.routines.find(zil.lowerCamelCase) != nil {
            return try Factories.RoutineCall(tokens, with: &localVariables)
        }

        if Game.findDefinition(zil.lowerCamelCase) != nil {
            return try Factories.DefinitionEvaluate(tokens, with: &localVariables)
        }

        throw GameError.factoryNotFound(zil)
    }
}

// MARK: - Reserved globals

extension Game {
    static var reservedGlobals: [Variable] {
        [
            Variable(id: "actions", type: .array(.string), category: .globals, isMutable: true),
            Variable(id: "preactions", type: .table, category: .globals, isMutable: true),
            Variable(id: "prsa", type: .int, category: .globals, isMutable: true),
            Variable(id: "prsi", type: .object, category: .globals, isMutable: true),
            Variable(id: "prso", type: .object, category: .globals, isMutable: true),
            Variable(id: "verbs", type: .table, category: .globals, isMutable: true),
        ]
    }
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

            􀀷 Z-machine version
            """,
            zMachineVersion.rawValue
        )
    }
}

// MARK: - GameError

enum GameError: Swift.Error {
    case factoryNotFound(String)
    case failedToProcessTokens([String])
    case globalNotFound(String)
    case invalidCommitType(Symbol)
    case invalidZMachineVersion([Token])
    case unexpectedAtRootLevel(Token)
    case unknownDirective([Token])
    case unknownOperation(String)
    case variableUpsertConflict(old: Variable, new: Variable)
}
