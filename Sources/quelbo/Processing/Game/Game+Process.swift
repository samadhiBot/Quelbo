//
//  Game+Process.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

extension Game {
    mutating func process(
        _ attempt: Int = 1,
        remainingCount: Int = 0
    ) throws {
        let count = remainingCount > 0 ? remainingCount : gameTokens.count
        print(
            """

            ⚙️  Processing attempt \(attempt), remaining tokens: \(count)
            ============================================================
            """
        )
        try processTokens()
        if gameTokens.isEmpty {
            return print("\nProcessing complete!\n")
        }
        if gameTokens.count == remainingCount {
            throw GameError.failedToProcessTokens(processingErrors)
        }
        try process(attempt + 1, remainingCount: gameTokens.count)
    }

    mutating func processTokens() throws {
        var unprocessedTokens: [Token] = []
        processingErrors = []
        try gameTokens.forEach { token in
            switch token {
            case .atom, .commented, .string:
                break // ignored
            case .bool, .decimal, .list, .quoted:
                throw GameError.unexpectedAtRootLevel(token)
            case .form(var tokens):
                do {
                    guard case .atom(let zil) = tokens.shift() else {
                        throw GameError.unknownDirective(tokens)
                    }
                    guard let factory = try Game.zilSymbolFactories.find(zil)?.init(tokens) else {
                        throw FactoryError.unknownZilFunction(zil: zil)
                    }
                    let symbol = try factory.process()
                    gameSymbols.append(symbol)
                } catch {
                    print("  - \(error)")
                    processingErrors.append("\(error)")
                    unprocessedTokens.append(token)
                }
            }
        }
        self.gameTokens = unprocessedTokens
    }
}

// MARK: - GameError

enum GameError: Swift.Error {
    case duplicateSymbolCommit(Symbol)
    case failedToProcessTokens([String])
    case symbolNotFound(String, category: String)
    case unexpectedAtRootLevel(Token)
    case unknownDirective([Token])
    case unknownOperation(String)
}

// MARK: - Symbol Categories

extension Game {
    /// <#Description#>
    static var directions: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .directions }
    }

    /// <#Description#>
    static var constants: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .constants }
            .sorted()
    }

    /// <#Description#>
    static var globals: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .globals }
            .sorted()
    }

    /// <#Description#>
    static var mutableGlobals: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .globals }
            .sorted()
    }

    /// <#Description#>
    static var objects: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .objects }
            .sorted()
    }

    /// <#Description#>
    static var rooms: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .rooms }
            .sorted()
    }

    /// <#Description#>
    static var routines: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .routines }
            .sorted()
    }
}
