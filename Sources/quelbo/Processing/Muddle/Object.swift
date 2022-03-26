//
//  Object.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/17/22.
//

import Foundation
import Swil

struct Object {
    var tokens: [Token]
    var definitions: [String] = []
    var directions: [String] = []
    let variety: Variety

    init(_ variety: Variety, _ tokens: [Token]) {
        self.tokens = tokens
        self.variety = variety
    }
}

extension Object {
    enum Variety: String {
        case object = "Object"
        case room   = "Room"

        var toDataType: Muddle.DataType {
            switch self {
            case .object: return .object
            case .room:   return .room
            }
        }

        var toDefType: Muddle.DefType {
            switch self {
            case .object: return .object
            case .room:   return .room
            }
        }
    }
}

extension Object {
    mutating func process() throws -> Muddle.Definition {
        guard case .atom(let zilName) = tokens.shiftAtom() else {
            throw Err.missingName
        }
        let name = zilName.lowerCamelCase
        while let listItem = tokens.shift() {
            guard case .list(var listTokens) = listItem else {
                if case .commented = listItem {
                    continue // ignore comments
                }
                throw Err.unexpectedToken("\(listItem) \(tokens)")
            }
            guard case .atom(let name) = listTokens.shiftAtom() else {
                throw Err.missingAttribute("\(listTokens)")
            }

            if let defName = Definition(rawValue: name),
               let definition = try processDefinition(defName, tokens: listTokens) {
                definitions.append(definition)
            } else if variety == .room {
                directions.append(try processDirection(name, dirTokens: listTokens))
            }
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("\(name) \(self) \(tokens)")
        }

        if variety == .room {
            definitions.append(
                """
                directions: [
                \(directions.sorted().joined(separator: ",\n").indented()),
                ]
                """
            )
        }
        definitions.sort()
        definitions.insert("name: \"\(name)\"", at: 0)

        return .init(
            name: name,
            code: """
                /// The `\(name)` (\(zilName)) \(variety.rawValue.lowercased()).
                var \(name) = \(variety.rawValue)(
                \(definitions.joined(separator: ",\n").indented())
                )
                """,
            dataType: variety.toDataType,
            defType: variety.toDefType,
            isMutable: true
        )
    }
}

private extension Object {
    enum Definition: String {
        case action              = "ACTION"
        case adjectives          = "ADJECTIVE"
        case attributes          = "FLAGS"
        case capacity            = "CAPACITY"
        case description         = "DESC"
        case descriptionFunction = "DESCFCN"
        case firstDescription    = "FDESC"
        case globals             = "GLOBAL"
        case longDescription     = "LDESC"
        case parent              = "IN"
        case pseudos             = "PSEUDO"
        case size                = "SIZE"
        case strength            = "STRENGTH"
        case synonyms            = "SYNONYM"
        case takeValue           = "TVALUE"
        case text                = "TEXT"
        case value               = "VALUE"
        case vType               = "VTYPE"
    }

    enum Err: Error {
        case invalidDirection(String)
        case invalidPseudo(String)
        case missingAttribute(String)
        case missingName
        case missingValue(String)
        case unconsumedTokens(String)
        case unexpectedToken(String)
    }

    func formatted(_ key: String, _ values: [String]) -> String {
        if values.count > 2 {
            return """
                \(key): [
                \(values.sorted().joined(separator: ",\n").indented()),
                ]
                """
        } else {
            return "\(key): [\(values.sorted().joined(separator: ", "))]"
        }
    }

    func processDefinition(
        _ definition: Definition,
        tokens: [Token]
    ) throws -> String? {
        var tokens = tokens

        switch definition {
        case .action:
            guard let value = tokens.shift() else {
                throw Err.missingValue("for action: \(tokens)")
            }
            return "action: \(try value.process())"
        case .adjectives:
            let values = try tokens.map { try $0.process().quoted() }
            return formatted("adjectives", values)
        case .attributes:
            let values = try tokens.compactMap { (token: Token) -> String? in
                guard case .atom(let zil) = token else {
                    if case .commented = token {
                        return nil
                    }
                    throw Err.missingValue("for attributes: \(tokens)")
                }
                return try Attribute(zil).case
            }
            return formatted("attributes", values)
        case .capacity:
            guard let value = tokens.shift() else {
                throw Err.missingValue("for capacity: \(tokens)")
            }
            return "capacity: \(try value.process())"
        case .description:
            guard let value = tokens.shift() else {
                throw Err.missingValue("for description: \(tokens)")
            }
            return "description: \(try value.process())"
        case .descriptionFunction:
            guard let value = tokens.shift() else {
                throw Err.missingValue("for descriptionFunction: \(tokens)")
            }
            return "descriptionFunction: \(try value.process())"
        case .firstDescription:
            guard let value = tokens.shift() else {
                throw Err.missingValue("for firstDescription: \(tokens)")
            }
            return "firstDescription: \(try value.process())"
        case .globals:
            let values = try tokens.map { try $0.process() }
            return formatted("globals", values)
        case .longDescription:
            guard let value = tokens.shift() else {
                throw Err.missingValue("for longDescription: \(tokens)")
            }
            return "longDescription: \(try value.process())"
        case .parent:
            guard let value = tokens.shiftAtom() else {
                throw Err.missingValue("for parent: \(tokens)")
            }
            guard tokens.isEmpty else {
                // Additional tokens means this refers to `in: Direction`, rather than `in: Room`
                return nil
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
        case .size:
            guard let value = tokens.shift() else {
                throw Err.missingValue("for size: \(tokens)")
            }
            return "size: \(try value.process())"
        case .strength:
            guard let value = tokens.shift() else {
                throw Err.missingValue("for strength: \(tokens)")
            }
            return "strength: \(try value.process())"
        case .synonyms:
            let values = try tokens.map { try $0.process().quoted() }
            return formatted("synonyms", values)
        case .takeValue:
            guard let value = tokens.shift() else {
                throw Err.missingValue("for takeValue: \(tokens)")
            }
            return "takeValue: \(try value.process())"
        case .text:
            guard let value = tokens.shift() else {
                throw Err.missingValue("for text: \(tokens)")
            }
            return "text: \(try value.process())"
        case .value:
            guard let value = tokens.shift() else {
                throw Err.missingValue("for value: \(tokens)")
            }
            return "value: \(try value.process())"
        case .vType:
            guard let value = tokens.shift() else {
                throw Err.missingValue("for vType: \(tokens)")
            }
            return "vType: \(try value.process())"
        }
    }

    func processDirection(
        _ direction: String,
        dirTokens: [Token]
    ) throws -> String {
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
            case .atom("SORRY"):
                guard case .string(let blockedMessage) = tokens.shift() else {
                    throw Err.invalidDirection("\(direction)")
                }
                message = blockedMessage
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
                    .\(name): .conditionalElse(\(destination),
                        if: \(condition),
                        else: \(message)
                    )
                    """
                }
                return ".\(name): .conditional(\(destination), if: \(condition))"
            }
            return ".\(name): .to(\(destination))"
        }

        if let message = message {
            return """
            .\(name): .blocked(\(message.quoted()))
            """
        }

        if let perFunction = perFunction {
            return ".\(name): .per(\(perFunction))"
        }

        throw Err.invalidDirection("\(dirTokens)")
    }
}
