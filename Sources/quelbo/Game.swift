//
//  Game.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Fizmo
import Parsing
import Foundation

/// <#Description#>
struct Game {
    /// <#Description#>
    let parser: AnyParser<Substring.UTF8View, Array<Token>>

    /// <#Description#>
    var processingErrors: [String]

    /// <#Description#>
    var gameTokens: [Token]

    /// <#Description#>
    var gameSymbols: [Symbol]

    private init() {
        let syntax = Syntax().parser

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
        self.processingErrors = []
        self.gameTokens = []
        self.gameSymbols = []
    }

    static var shared = Game()
}

// MARK: - Game symbol storage

extension Game {
    static func commit(_ symbols: Symbol...) throws {
        try commit(symbols)
    }

    static func commit(_ symbols: [Symbol]) throws {
        try symbols.forEach { symbol in
            guard !shared.gameSymbols.contains(symbol) else {
//                print("⚠️ Conflicting symbol definition \(symbol)")
                throw GameError.duplicateSymbolCommit(symbol)
//                return
            }
//            print("  ✅ committing \(symbol.id)")
            shared.gameSymbols.append(symbol)
        }
    }

    static func find(_ name: String, category: Symbol.Category? = nil) throws -> Symbol {
        guard
            let symbol = shared.gameSymbols.first(where: {
                guard let category = category else {
                    return $0.id == name
                }
                return $0.id == name && $0.category == category
            })
        else {
            if let category = category {
                throw GameError.symbolNotFound(name, category: "\(category)")
            } else {
                throw GameError.symbolNotFound(name, category: "any")
            }
        }
        return symbol
    }
}
