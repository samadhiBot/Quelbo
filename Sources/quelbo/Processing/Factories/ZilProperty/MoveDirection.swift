//
//  MoveDirection.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/17/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the movement direction properties of a Zil
    /// [ROOM](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.13qzunr)
    /// type.
    class MoveDirection: ZilPropertyFactory {
        static func find(_ zil: String) -> MoveDirection.Type? {
            let name = zil.lowerCamelCase
            let direction = Factories.Directions.Improved(rawValue: name)?.name ?? name
            guard Game.directions.find(id: .init(stringLiteral: direction)) != nil else {
                return nil
            }
            return Factories.MoveDirection.self
        }

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
            let name = try findNameSymbol(in: &tokens).code
            self.name = Factories.Directions.Improved(rawValue: name)?.name ?? name

            while let token = tokens.shift() {
                switch token {
                    case .atom("TO"):
                        guard case .atom(let room) = tokens.shift() else {
                            throw FactoryError.invalidProperty(token)
                        }
                        self.destination = room.lowerCamelCase
                    case .atom("PER"):
                        guard case .atom(let function) = tokens.shift() else {
                            throw FactoryError.invalidProperty(token)
                        }
                        self.perFunction = function.lowerCamelCase
                    case .atom("IF"):
                        guard case .atom(let cond) = tokens.shift() else {
                            throw FactoryError.invalidProperty(token)
                        }
                        self.condition = cond.lowerCamelCase
                    case .atom("IS"):
                        guard case .atom(let cond) = tokens.shift() else {
                            throw FactoryError.invalidProperty(token)
                        }
                        self.condition?.append(".is\(cond.upperCamelCase)")
                    case .atom("ELSE"):
                        guard case .string(let elseMessage) = tokens.shift() else {
                            throw FactoryError.invalidProperty(token)
                        }
                        self.message = elseMessage
                    case .atom("SORRY"):
                        guard case .string(let blockedMessage) = tokens.shift() else {
                            throw FactoryError.invalidProperty(token)
                        }
                        self.message = blockedMessage
                    case .string(let blockedMessage):
                        self.message = blockedMessage
                    default:
                        throw FactoryError.invalidProperty(token)
                }
            }
        }

        override func process() throws -> Symbol {
            if let destination = destination {
                if let condition = condition {
                    if let message = message {
                        return Symbol(
                            id: .init(stringLiteral: name),
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
                        id: .init(stringLiteral: name),
                        code: ".\(name): .conditional(\(destination), if: \(condition))",
                        type: Self.returnType
                    )
                }
                return Symbol(
                    id: .init(stringLiteral: name),
                    code: ".\(name): .to(\(destination))",
                    type: Self.returnType
                )
            }
            if let message = message {
                return Symbol(
                    id: .init(stringLiteral: name),
                    code: ".\(name): .blocked(\(message.quoted))",
                    type: Self.returnType
                )
            }
            if let perFunction = perFunction {
                return Symbol(
                    id: .init(stringLiteral: name),
                    code: ".\(name): .per(\(perFunction))",
                    type: Self.returnType
                )
            }
            throw FactoryError.invalidDirection(tokens)
        }
    }
}
