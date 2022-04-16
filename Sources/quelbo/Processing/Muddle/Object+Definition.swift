////
////  Object+Definition.swift
////  Quelbo
////
////  Created by Chris Sessions on 3/17/22.
////
//
//import Foundation
//import Fizmo
//
//extension Object {
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
//}
//
//extension Object.Definition {
//    enum Err: Error {
//        case invalidPseudo(String)
//        case missingValue(String)
//        case unexpectedToken(String)
//    }
//
//    func formatted(_ key: String, _ values: [String]) -> String {
//        if values.count > 2 {
//            return """
//                \(key): [
//                \(values.sorted().joined(separator: ",\n").indented),
//                ]
//                """
//        } else {
//            return "\(key): [\(values.sorted().joined(separator: ", "))]"
//        }
//    }
//
//    func process(
//        tokens: [Token]
//    ) throws -> Symbol? {
//        var tokens = tokens
//
//        switch self {
//        case .action:
//            guard let value = try tokens.shift()?.process() else {
//                throw Err.missingValue("for action: \(tokens)")
//            }
//            return .init(
//                code: "action: \(value)", type:
//                    value.type
//            )
//        case .adjectives:
//            let values = try tokens.map { try $0.process().description.quoted }
//            return .init(
//                code: formatted("adjectives", values), type: .
//                array(.string)
//            )
//        case .attributes:
//            let values = try tokens.compactMap { (token: Token) -> String? in
//                guard case .atom(let zil) = token else {
//                    if case .commented = token {
//                        return nil
//                    }
//                    throw Err.missingValue("for attributes: \(tokens)")
//                }
//                return try Attribute(zil).case
//            }
//            return .init(
//                code: formatted("attributes", values),
//                type: .bool
//            )
//        case .capacity:
//            guard let value = tokens.shift() else {
//                throw Err.missingValue("for capacity: \(tokens)")
//            }
//            return .init(
//                code: "capacity: \(try value.process())",
//                type: .int
//            )
//        case .description:
//            guard let value = tokens.shift() else {
//                throw Err.missingValue("for description: \(tokens)")
//            }
//            return .init(
//                code: "description: \(try value.process())",
//                type: .string
//            )
//        case .descriptionFunction:
//            guard let value = tokens.shift() else {
//                throw Err.missingValue("for descriptionFunction: \(tokens)")
//            }
//            return .init(
//                code: "description: \(try value.process())",
//                type: .string
//            )
//        case .firstDescription:
//            guard let value = tokens.shift() else {
//                throw Err.missingValue("for firstDescription: \(tokens)")
//            }
//            return .init(
//                code: "firstDescription: \(try value.process())",
//                type: .string
//            )
//        case .globals:
//            let values = try tokens.map { try $0.process().description }
//            return .init(
//                code: formatted("globals", values),
//                type: .string
//            )
//        case .longDescription:
//            guard let value = tokens.shift() else {
//                throw Err.missingValue("for longDescription: \(tokens)")
//            }
//            return .init(
//                code: "longDescription: \(try value.process())",
//                type: .string
//            )
//        case .parent:
//            guard let value = tokens.shiftAtom() else {
//                throw Err.missingValue("for parent: \(tokens)")
//            }
//            guard tokens.isEmpty else {
//                // Additional tokens means this refers to `in: Direction`, rather than `in: Room`
//                return nil
//            }
//            return .init(
//                code: "parent: \(try value.process())",
//                type: .room
//            )
//        case .pseudos:
//            var pseudos: [String: String] = [:]
//            while !tokens.isEmpty {
//                guard
//                    case .string(let key) = tokens.shift(),
//                    case .atom(let value) = tokens.shift()
//                else {
//                    throw Err.invalidPseudo("\(pseudos) \(tokens)")
//                }
//                pseudos[key.lowerCamelCase] = value.lowerCamelCase
//            }
//            return .init(code: """
//                pseudos: [
//                \(pseudos.map { "\"\($0)\": \($1)" }.sorted().joined(separator: ",\n").indented)
//                ]
//                """,
//                type: nil
//            )
//        case .size:
//            guard let value = tokens.shift() else {
//                throw Err.missingValue("for size: \(tokens)")
//            }
//            return .init(
//                code: "size: \(try value.process())",
//                type: .int
//            )
//        case .strength:
//            guard let value = tokens.shift() else {
//                throw Err.missingValue("for strength: \(tokens)")
//            }
//            return .init(
//                code: "strength: \(try value.process())",
//                type: .int
//            )
//        case .synonyms:
//            let values = try tokens.map { try $0.process().description.quoted }
//            return .init(
//                code: formatted("synonyms", values), type: .
//                array(.string)
//            )
//        case .takeValue:
//            guard let value = tokens.shift() else {
//                throw Err.missingValue("for takeValue: \(tokens)")
//            }
//            return .init(
//                code: "takeValue: \(try value.process())",
//                type: .int
//            )
//        case .text:
//            guard let value = tokens.shift() else {
//                throw Err.missingValue("for text: \(tokens)")
//            }
//            return .init(
//                code: "text: \(try value.process())",
//                type: .string
//            )
//        case .value:
//            guard let value = tokens.shift() else {
//                throw Err.missingValue("for value: \(tokens)")
//            }
//            return .init(
//                code: "value: \(try value.process())",
//                type: .int
//            )
//        case .vType:
//            guard let value = tokens.shift() else {
//                throw Err.missingValue("for vType: \(tokens)")
//            }
//            return .init(
//                code: "vType: \(try value.process())",
//                type: .string
//            )
//        }
//    }
//}
