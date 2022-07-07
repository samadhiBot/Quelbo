//
//  Game.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Fizmo
import Parsing
import Foundation

/// A container for a Zil to Swift game translation.
///
class Game {
    /// A parser that translates raw Zil code into Swift ``Token`` values.
    let parser: AnyParser<Substring.UTF8View, Array<Token>>

    /// An array of any errors encountered during game processing.
    var processingErrors: [String] = []

    /// An array of ``Token`` values parsed from the raw Zil code.
    var gameTokens: [Token] = []

    /// An array of ``Symbol`` values processed from the ``gameTokens``.
    var gameSymbols: [Symbol] = []

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
    /// Commit one or more processed ``Symbol`` values to the known ``gameSymbols``.
    ///
    /// - Parameter symbols: One or more symbol values to commit.
    static func commit(_ symbols: Symbol...) {
        commit(symbols)
    }

    /// Commit an array of processed ``Symbol`` values to the known ``gameSymbols``.
    ///
    /// - Parameter symbols: An array of symbol values to commit.
    static func commit(_ symbols: [Symbol]) {
        symbols.forEach { symbol in
            _ = upsert(symbol)
        }
    }

    /// Find a ``Symbol`` in the committed ``gameSymbols`` whose ``Symbol/id``, ``Symbol/type`` and
    /// ``Symbol/category-swift.property`` match those specified.
    ///
    /// - Parameters:
    ///   - id: The symbol id to match.
    ///   - type: The symbol type to match.
    ///   - category: One or more categories, any of which the symbol should belong.
    ///
    /// - Returns: A symbol that matches the specified `id`, `type` and `category`.
    ///
    /// - Throws: When a matching symbol does not currently exist in the ``gameSymbols``.
    static func find(
        _ id: Symbol.Identifier,
        type: Symbol.DataType? = nil,
        category categories: Symbol.Category...
    ) throws -> Symbol {
        guard let symbol = shared.gameSymbols.first(where: {
            if $0.id != id {
                return false
            }
            if let type = type, type.isUnambiguous, $0.type != type {
                return false
            }
            if let symbolCategory = $0.category, !categories.isEmpty {
                return categories.contains(symbolCategory)
            }
            return true
        }) else {
            throw GameError.symbolNotFound(id, categories: categories)
        }
        return symbol
    }

    /// Inserts or updates a ``Symbol`` in the known ``gameSymbols``.
    ///
    /// - Parameter symbol: The revised symbol to insert or reconcile with a committed symbol.
    ///
    /// - Returns: The reconciled and committed symbol.
    static func upsert(_ symbol: Symbol) -> Symbol {
        assert(symbol.isIdentifiable)

        if let existing = shared.gameSymbols.find(id: symbol.id) {
            return existing.reconcile(with: symbol)
        } else {
            shared.gameSymbols.append(symbol)
            return symbol
        }
    }
}

// MARK: - GameError

enum GameError: Swift.Error {
    case conflictingDuplicateSymbolCommit(old: Symbol, new: Symbol)
    case failedToProcessTokens([String])
    case invalidZMachineVersion([Token])
    case symbolNotFound(Symbol.Identifier, categories: [Symbol.Category])
    case unexpectedAtRootLevel(Token)
    case unknownDirective([Token])
    case unknownOperation(String)
}
