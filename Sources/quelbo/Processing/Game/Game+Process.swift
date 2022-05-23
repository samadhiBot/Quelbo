//
//  Game+Process.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

extension Game {
    func process(
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

    func processTokens() throws {
        var unprocessedTokens: [Token] = []
        processingErrors = []
        try gameTokens.forEach { token in
            switch token {
            case .bool, .character, .decimal, .global, .list, .local, .quote, .vector:
                throw GameError.unexpectedAtRootLevel(token)
            case .form(let formTokens):
                do {
                    var tokens = formTokens
                    guard case .atom(let zil) = tokens.shift() else {
                        throw GameError.unknownDirective(tokens)
                    }
                    let factory: SymbolFactory
                    if let zilSymbol = try Game.zilSymbolFactories.find(zil)?.init(tokens) {
                        factory = zilSymbol
                    } else {
                        factory = try Factories.Evaluate(formTokens)
                    }
                    _ = try factory.process()
                } catch {
                    print("  - \(error)")
                    processingErrors.append("\(error)")
                    unprocessedTokens.append(token)
                }
            default:
                break // ignored
            }
        }
        self.gameTokens = unprocessedTokens
    }

    func setZMachineVersion() throws {
        for token in gameTokens {
            guard
                case .form(var formTokens) = token,
                case .atom("VERSION") = formTokens.shift()
            else {
                continue
            }
            self.zMachineVersion = try Game.ZMachineVersion(tokens: formTokens)
            break
        }

        print(
            """

            💾  Z-machine version \(zMachineVersion)
            ============================================================
            """
        )
    }
}

// MARK: - GameError

enum GameError: Swift.Error {
    case duplicateSymbolCommit(Symbol)
    case failedToProcessTokens([String])
    case invalidZMachineVersion([Token])
    case symbolNotFound(String, category: String)
    case unexpectedAtRootLevel(Token)
    case unknownDirective([Token])
    case unknownOperation(String)
}

// MARK: - Symbol Categories

extension Game {
    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/directions`` category.
    static var directions: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .directions }
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/constants`` category.
    static var constants: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .constants }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/globals`` category.
    static var globals: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .globals }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/objects`` category.
    static var objects: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .objects }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/rooms`` category.
    static var rooms: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .rooms }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/routines`` category.
    static var routines: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .routines }
            .sorted
    }
}

// MARK: - Game.ZMachineVersion

extension Game {
    /// The ZMachine version to emulate during processing.
    /// 
    enum ZMachineVersion: String {
        case z3
        case z3Time
        case z4
        case z5
        case z6
        case z7
        case z8

        init(tokens: [Token]) throws {
            guard (1...2).contains(tokens.count) else {
                throw GameError.invalidZMachineVersion(tokens)
            }
            switch tokens[0] {
            case .atom("ZIP"), .decimal(3):
                if case .atom("TIME") = tokens.last {
                    self = .z3Time
                } else {
                    self = .z3
                }
            case .atom("EZIP"), .decimal(4):
                self = .z4
            case .atom("XZIP"), .decimal(5):
                self = .z5
            case .atom("YZIP"), .decimal(6):
                self = .z6
            case .decimal(7):
                self = .z7
            case .decimal(8):
                self = .z8
            default:
                throw GameError.invalidZMachineVersion(tokens)
            }
        }

        /// An integer representation of the ZMachine version.
        var intValue: Int {
            switch self {
            case .z3:     return 3
            case .z3Time: return 3
            case .z4:     return 4
            case .z5:     return 5
            case .z6:     return 6
            case .z7:     return 7
            case .z8:     return 8
            }
        }
    }
}
