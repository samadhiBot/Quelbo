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
    static func commit(_ symbols: Symbol...) throws {
        try commit(symbols)
    }

    /// Commit an array of processed ``Symbol`` values to the known ``gameSymbols``.
    ///
    /// - Parameter symbols: An array of symbol values to commit.
    static func commit(_ symbols: [Symbol]) throws {
        try symbols.forEach { symbol in
            guard !shared.gameSymbols.contains(symbol) else {
                throw GameError.duplicateSymbolCommit(symbol)
            }
            shared.gameSymbols.append(symbol)
        }
    }

    /// Find a ``Symbol`` in the committed ``gameSymbols`` whose ``Symbol/id`` and
    /// ``Symbol/category-swift.property`` match the ones specified.
    ///
    /// - Parameters:
    ///   - id: The symbol `id` to match.
    ///   - category: The symbol `category` to match.
    ///
    /// - Returns: A symbol that matches the specified `id` and `category`.
    ///
    /// - Throws: When a matching symbol does not currently exist in the ``gameSymbols``.
    static func find(
        _ id: String,
        category: Symbol.Category? = nil
    ) throws -> Symbol {
        guard
            let symbol = shared.gameSymbols.first(where: {
                guard let category = category else {
                    return $0.id == id
                }
                return $0.id == id && $0.category == category
            })
        else {
            throw GameError.symbolNotFound(id, category: category?.rawValue ?? "any")
        }
        return symbol
    }
}
