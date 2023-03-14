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
    class MoveDirection: Factory {
        var condition: String?
        var conditionSuffix: String?
        var destination: String?
        var message: String?
        var name: String = ""
        var perFunction: String?

        override func processTokens() throws {
            var tokens = tokens

            let zilName = try findName(in: &tokens)

            if let predefined = Direction.find(zilName) {
                self.name = predefined.id.description
            } else if let property = Game.properties.find(zilName.lowerCamelCase) {
                guard let propertyID = property.id else {
                    throw Error.unknownDirection(zilName)
                }
                self.name = propertyID
            } else {
                throw Error.unknownDirection(zilName)
            }

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
                    self.conditionSuffix = "is\(cond.upperCamelCase)"
                case .atom("ELSE"):
                    guard case .string(let elseMessage) = tokens.shift() else {
                        throw Error.invalidElseDirectionParameter(token)
                    }
                    self.message = elseMessage.quoted
                case .atom("SORRY"):
                    guard case .string(let blockedMessage) = tokens.shift() else {
                        throw Error.invalidSorryDirectionParameter(token)
                    }
                    self.message = blockedMessage.quoted
                case .string(let blockedMessage):
                    self.message = blockedMessage.quoted
                default:
                    throw Error.invalidDirectionParameter(token)
                }
            }
        }

        func code() throws -> String {
            if let destination {
                if let condition {
                    var conditionCode: String {
                        if let conditionSuffix {
                            return "\(condition).\(conditionSuffix)"
                        }
                        return condition
                    }
                    if let message {
                        return """
                            .\(name): .conditionalElse(\(destination.quoted),
                                if: \(conditionCode.quoted),
                                else: \(message)
                            )
                            """
                    }
                    return ".\(name): .conditional(\(destination.quoted), if: \(conditionCode.quoted))"
                }
                return ".\(name): .to(\(destination.quoted))"
            }
            if let message {
                return ".\(name): .blocked(\(message))"
            }
            if let perFunction {
                return ".\(name): .per(\(perFunction.quoted))"
            }
            throw Error.invalidDirectionParameters(tokens)
        }

        override func process() throws -> Symbol {
            let moveDirectionCode = try code()

            return .statement(
                code: { _ in
                    moveDirectionCode
                },
                type: .object
            )
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
        case unknownDirection(String)
    }
}
