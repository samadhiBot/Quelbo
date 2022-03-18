//
//  Object.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/17/22.
//

import Foundation

struct Object {
    var tokens: [Token]
    var attributes: [String] = []

    init(_ tokens: [Token]) {
        self.tokens = tokens
    }
}

extension Object {
    mutating func process() throws -> Muddle.Definition {
        guard case .atom(let zilName) = tokens.shiftAtom() else {
            throw Err.missingName
        }
        let name = zilName.lowerCamelCase
        while let attribute = tokens.shift() {
            guard case .list(let listTokens) = attribute else {
                if case .commented = attribute {
                    continue // ignore comments
                }
                throw Err.unexpectedToken("\(attribute) \(tokens)")
            }
            attributes.append(try process(listTokens))
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("set \(name) \(self) \(tokens)")
        }

        attributes.sort()
        attributes.insert("name: \"\(name)\"", at: 0)

        return .init(
            name: name,
            code: """
                /// The `\(name)` (\(zilName)) object.
                var \(name) = Object(
                \(attributes.joined(separator: ",\n").indented())
                )
                """,
            dataType: .object,
            defType: .object
        )
    }
}

private extension Object {
    enum Attribute: String {
        case action              = "ACTION"
        case adjectives          = "ADJECTIVE"
        case capacity            = "CAPACITY"
        case description         = "DESC"
        case descriptionFunction = "DESCFCN"
        case firstDescription    = "FDESC"
        case flags               = "FLAGS"
        case longDescription     = "LDESC"
        case parent              = "IN"
        case size                = "SIZE"
        case strength            = "STRENGTH"
        case synonyms            = "SYNONYM"
        case takeValue           = "TVALUE"
        case text                = "TEXT"
        case value               = "VALUE"
        case vType               = "VTYPE"
    }

    enum Err: Error {
        case missingAttribute(String)
        case missingName
        case missingValue(String)
        case unconsumedTokens(String)
        case unexpectedToken(String)
        case unknownAttribute(String)
    }

    mutating func process(_ listTokens: [Token]) throws -> String {
        var tokens = listTokens
        guard case .atom(let name) = tokens.shiftAtom() else {
            throw Err.missingAttribute("\(listTokens)")
        }
        guard let attribute = Attribute(rawValue: name) else {
            throw Err.unknownAttribute("\(name) \(tokens)")
        }

        return try process(attribute, tokens: tokens)
    }

    func process(_ attribute: Attribute, tokens: [Token]) throws -> String {
        var tokens = tokens

        switch attribute {
        case .action:
            guard let value = tokens.shiftAtom() else {
                throw Err.missingValue("action")
            }
            return "action: \(try value.process())"
        case .adjectives:
            let values = try tokens.map { try $0.process().quoted() }.joined(separator: ", ")
            return "adjectives: [\(values)]"
        case .capacity:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "capacity: \(try value.process())"
        case .description:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "description: \(try value.process())"
        case .descriptionFunction:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "descriptionFunction: \(try value.process())"
        case .firstDescription:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "firstDescription: \(try value.process())"
        case .flags:
            let values = try tokens.map { try $0.process() }.joined(separator: ", ")
            return "flags: [\(values)]"
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
        case .size:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "size: \(try value.process())"
        case .strength:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "strength: \(try value.process())"
        case .synonyms:
            let values = try tokens.map { try $0.process().quoted() }.joined(separator: ", ")
            return "synonyms: [\(values)]"
        case .takeValue:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "takeValue: \(try value.process())"
        case .text:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "text: \(try value.process())"
        case .value:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "value: \(try value.process())"
        case .vType:
            guard let value = tokens.shift() else {
                throw Err.missingValue("action")
            }
            return "vType: \(try value.process())"
        }
    }
}
