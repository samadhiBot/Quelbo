//
//  Room.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/18/22.
//

import Foundation

struct Room {
    var tokens: [Token]
    var attributes: [String] = []
    var directions: [String] = []

    init(_ tokens: [Token]) {
        self.tokens = tokens
    }
}

extension Room {
    mutating func process() throws -> Muddle.Definition {
        guard case .atom(let zilName) = tokens.shiftAtom() else {
            throw Err.missingName
        }
        let name = zilName.lowerCamelCase
        while let attribute = tokens.shift() {
            guard case .list(var listTokens) = attribute else {
                if case .commented = attribute {
                    continue // ignore comments
                }
                throw Err.unexpectedToken("\(attribute) \(tokens)")
            }
            guard case .atom(let name) = listTokens.shiftAtom() else {
                throw Err.missingAttribute("\(listTokens)")
            }
            if let attribute = Attribute(rawValue: name) {
                attributes.append(try process(attribute, tokens: listTokens))
            } else {
                directions.append(try process(name, dirTokens: listTokens))
            }
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("set \(name) \(self) \(tokens)")
        }

        attributes.append(
            """
            directions: [
            \(directions.joined(separator: "\n").indented())
            ]
            """
        )
        attributes.sort()
        attributes.insert("name: \"\(name)\"", at: 0)

        return .init(
            name: name,
            code: """
                /// The `\(name)` (\(zilName)) Room.
                var \(name) = Room(
                \(attributes.joined(separator: ",\n").indented())
                )
                """,
            dataType: .room,
            defType: .room
        )
    }
}

private extension Room {
    enum Attribute: String {
        case action          = "ACTION"
        case description     = "DESC"
        case flags           = "FLAGS"
        case globals         = "GLOBAL"
        case longDescription = "LDESC"
        case parent          = "IN"
        case pseudos         = "PSEUDO"
        case value           = "VALUE"
    }

    enum Err: Error {
        case invalidDirection(String)
        case invalidPseudo(String)
        case missingAttribute(String)
        case missingName
        case missingValue(String)
        case unconsumedTokens(String)
        case unexpectedToken(String)
        case unknownAttribute(String)
    }

    func process(_ attribute: Attribute, tokens: [Token]) throws -> String {
        var tokens = tokens

        switch attribute {
        case .action:
            guard let value = tokens.shiftAtom() else {
                throw Err.missingValue("action")
            }
            return "action: \(try value.process())"
        case .description:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "description: \(try value.process())"
        case .flags:
            let values = try tokens.map { try $0.process() }.joined(separator: ", ")
            return "flags: [\(values)]"
        case .globals:
            let values = try tokens.map { try $0.process() }.joined(separator: ", ")
            return "globals: [\(values)]"
        case .longDescription:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "longDescription: \(try value.process())"
        case .parent:
            guard let value = tokens.shiftAtom() else {
                throw Err.missingValue("action")
            }
            return "parent: \(try value.process())"
        case .pseudos:
            var pseudos: [String: String] = [:]
            while !tokens.isEmpty {
                guard
                    case .string(let key) = tokens.shift(),
                    case .atom(let value) = tokens.shift()
                else {
                    throw Err.invalidPseudo("\(pseudos) \(tokens)")
                }
                pseudos[key.lowerCamelCase] = value.lowerCamelCase
            }
            return """
                pseudos: [
                \(pseudos.map { "\"\($0)\": \($1)" }.sorted().joined(separator: ",\n").indented())
                ]
                """

        case .value:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "value: \(try value.process())"
        }
    }

    func process(_ direction: String, dirTokens: [Token]) throws -> String {
        var tokens = dirTokens
        let name = Direction.name(for: direction)

        var condition: String?
        var destination: String?
        var message: String?
        var perFunction: String?

        while !tokens.isEmpty {
            guard let token = tokens.shift() else {
                throw Err.invalidDirection("\(direction)")
            }
            switch token {
            case .atom("TO"):
                guard let room = try tokens.shiftAtom()?.process() else {
                    throw Err.invalidDirection("\(direction)")
                }
                destination = room
            case .atom("PER"):
                guard let function = try tokens.shiftAtom()?.process() else {
                    throw Err.invalidDirection("\(direction)")
                }
                perFunction = function
            case .atom("IF"):
                guard let cond = try tokens.shiftAtom()?.process() else {
                    throw Err.invalidDirection("\(direction)")
                }
                condition = cond
            case .atom("IS"):
                guard case .atom(let cond) = tokens.shift() else {
                    throw Err.invalidDirection("\(direction)")
                }
                condition?.append(".is\(cond.upperCamelCase)")
            case .atom("ELSE"):
                guard let elseMessage = try tokens.shift()?.process() else {
                    throw Err.invalidDirection("\(direction)")
                }
                message = elseMessage
            case .string(let blockedMessage):
                message = blockedMessage
            default:
                throw Err.unexpectedToken("\(token) \(dirTokens)")
            }
        }

        if let destination = destination {
            if let condition = condition {
                if let message = message {
                    return """
                    \(name): .conditionalElse(
                        to: \(destination),
                        if: \(condition),
                        else: \(message)
                    )
                    """
                }
                return """
                \(name): .conditional(
                    to: \(destination),
                    if: \(condition)
                )
                """
            }
            return "\(name): .to(\(destination))"
        }

        if let message = message {
            return """
            \(name): .blocked(message: \(message.quoted()))
            """
        }

        if let perFunction = perFunction {
            return "\(name): .per(\(perFunction))"
        }

        throw Err.invalidDirection("\(dirTokens)")
    }
}
