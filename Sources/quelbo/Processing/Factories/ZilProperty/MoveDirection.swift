//
//  MoveDirection.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/17/22.
//

import Fizmo
import Foundation

extension Factories {
    /// A symbol factory for the movement direction properties of a Zil
    /// [ROOM](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.13qzunr)
    /// type.
    class MoveDirection: ZilPropertyFactory {
        override class var returnType: Symbol.DataType {
            .direction
        }

        var condition: String?
        var destination: String?
        var message: String?
        var name: String = ""
        var perFunction: String?

        override func processTokens() throws {
            var tokens = tokens
            let dirSymbol = try findNameSymbol(in: &tokens)
            var direction = dirSymbol.id.stringLiteral

            if let predefined = Direction.find(dirSymbol.zilName) {
                direction = predefined.id.description
            }
            self.name = try Game.find(
                .id(direction),
                category: .properties
            ).id.stringLiteral

            while let token = tokens.shift() {
                switch token {
                    case .atom("TO"):
                        guard case .atom(let room) = tokens.shift() else {
                            throw Error.invalidToDirectionParameter(token)
                        }
                        self.destination = room.lowerCamelCase
                    case .atom("PER"):
                        guard case .atom(let function) = tokens.shift() else {
                            throw Error.invalidPerDirectionParameter(token)
                        }
                        self.perFunction = function.lowerCamelCase
                    case .atom("IF"):
                        guard case .atom(let cond) = tokens.shift() else {
                            throw Error.invalidIfDirectionParameter(token)
                        }
                        self.condition = cond.lowerCamelCase
                    case .atom("IS"):
                        guard case .atom(let cond) = tokens.shift() else {
                            throw Error.invalidIsDirectionParameter(token)
                        }
                        self.condition?.append(".is\(cond.upperCamelCase)")
                    case .atom("ELSE"):
                        guard case .string(let elseMessage) = tokens.shift() else {
                            throw Error.invalidElseDirectionParameter(token)
                        }
                        self.message = elseMessage
                    case .atom("SORRY"):
                        guard case .string(let blockedMessage) = tokens.shift() else {
                            throw Error.invalidSorryDirectionParameter(token)
                        }
                        self.message = blockedMessage
                    case .string(let blockedMessage):
                        self.message = blockedMessage
                    default:
                        throw Error.invalidDirectionParameter(token)
                }
            }
        }

        override func process() throws -> Symbol {
            if let destination = destination {
                if let condition = condition {
                    if let message = message {
                        return Symbol(
                            id: .id(name),
                            code: """
                                .\(name): .conditionalElse(\(destination),
                                    if: \(condition),
                                    else: \(message)
                                )
                                """,
                            type: Self.returnType
                        )
                    }
                    return Symbol(
                        id: .id(name),
                        code: ".\(name): .conditional(\(destination), if: \(condition))",
                        type: Self.returnType
                    )
                }
                return Symbol(
                    id: .id(name),
                    code: ".\(name): .to(\(destination))",
                    type: Self.returnType
                )
            }
            if let message = message {
                return Symbol(
                    id: .id(name),
                    code: ".\(name): .blocked(\(message.quoted))",
                    type: Self.returnType
                )
            }
            if let perFunction = perFunction {
                return Symbol(
                    id: .id(name),
                    code: ".\(name): .per(\(perFunction))",
                    type: Self.returnType
                )
            }
            throw Error.invalidDirectionParameters(tokens)
        }
    }
}

// MARK: - Errors

extension Factories.MoveDirection {
    enum Error: Swift.Error {
        case invalidDirectionParameter(Token)
        case invalidDirectionParameters([Token])
        case invalidElseDirectionParameter(Token)
        case invalidIfDirectionParameter(Token)
        case invalidIsDirectionParameter(Token)
        case invalidPerDirectionParameter(Token)
        case invalidSorryDirectionParameter(Token)
        case invalidToDirectionParameter(Token)
    }
}
