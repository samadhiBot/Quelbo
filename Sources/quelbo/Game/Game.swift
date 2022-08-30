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
    /// A parser that translates raw Zil code into Swift ``Token`` values.
    let parser: AnyParser<Substring.UTF8View, Array<Token>>

    /// <#Description#>
    var definitions: [Definition] = []

    /// An array of any errors encountered during game processing.
    var errors: [String] = []

    /// An array of ``Token`` values parsed from the raw Zil code.
    var tokens: [Token] = []

    /// An array of ``Symbol`` symbols processed from the `tokens`.
    var symbols: [Symbol] = []

    /// <#Description#>
    var globalVariables: [Variable] = []

    /// The ZMachine version to emulate during processing.
    var zMachineVersion: Game.ZMachineVersion = .z3

    private init() {
        let syntax = ZilSyntax().parser

        let parser = Parse {
            Many {
                syntax
            } separator: {
                Whitespace()
            }
            End()
        }
        .eraseToAnyParser()

        self.parser = parser
    }

    /// A shared instance of the ``Game`` representation.
    static var shared = Game()
}

// MARK: - Game symbol storage

extension Game {
    /// <#Description#>
    /// - Parameter symbol: <#symbol description#>
    static func commit(_ symbol: Symbol) throws {
        try commit([symbol])
    }

    /// Commit an array of processed ``Variable`` values to the known ``globalVariables``.
    ///
    /// - Parameter variables: An array of variables to commit.
    static func commit(_ symbols: [Symbol]) throws {
        for symbol in symbols {
            switch symbol {
            case .definition(let definition):
                shared.definitions.append(definition)
            case .statement:
                shared.symbols.append(symbol)
            case .instance, .literal:
                throw GameError.invalidCommitType(symbol)
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
        root: Bool = false
    ) -> Factory.Type? {
        let found = factories.filter { $0.zilNames.contains(id) }
        switch found.count {
        case 0: return nil
        case 1: return found[0]
        default: return found.first { root == $0.muddle }
        }
    }

    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Returns: <#description#>
    static func findGlobal(_ id: String) -> Variable? {
        shared.globalVariables.first { $0.id == id }
    }

    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Returns: <#description#>
    static func findPropertyFactory(_ id: String) -> PropertyFactory.Type? {
        let found = propertyFactories.filter { $0.zilNames.contains(id) }
        switch found.count {
        case 0: return nil
        case 1: return found[0]
        default: fatalError()
        }
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
        _ zil: String,
        tokens: [Token],
        with localVariables: inout [Variable]
    ) throws -> Factory {
        if let factory = factories.first(where: { $0.zilNames.contains(zil)}) {
            return try factory.init(
                tokens.droppingFirst,
                with: &localVariables
            )
        }

        if Game.routines.find(zil.lowerCamelCase) != nil {
            return try Factories.RoutineCall(tokens, with: &localVariables)
        }

        if Game.findDefinition(zil.lowerCamelCase) != nil {
            try Factories.DefinitionEvaluate(tokens, with: &localVariables).process()
            return try Factories.RoutineCall(tokens, with: &localVariables)
        }

        throw GameError.factoryNotFound(zil)
    }

    /// <#Description#>
    static let propertyFactories = _Runtime
        .subclasses(of: PropertyFactory.self)
        .map { $0 as! PropertyFactory.Type }

    /// Inserts or updates a ``Symbol`` in the known ``gameSymbols``.
    ///
    /// - Parameter symbol: The revised symbol to insert or reconcile with a committed symbol.
    ///
    /// - Returns: The reconciled and committed symbol.
//    @discardableResult static func upsert(_ variable: Variable) throws -> Variable {
//        guard let found = findGlobal(variable.id) else {
//            shared.globalVariables.append(variable)
//            return variable
//        }
//
//        if found == variable { return found }
//
//        if variable.confidence > found.confidence {
//            found.confidence = variable.confidence
//            found.type = variable.type
//            return found
//        }
//
//        if variable.confidence < found.confidence {
//            return found
//        }
//
//        throw GameError.variableUpsertConflict(old: found, new: variable)
//    }
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
