////
////  Object.swift
////  Quelbo
////
////  Created by Chris Sessions on 3/17/22.
////
//
//import Foundation
//import Fizmo
//
//struct Object {
//    var tokens: [Token]
//    var symbols: [Symbol] = []
//    var directions: [Symbol] = []
//    let variety: Variety
//
//    init(_ variety: Variety, _ tokens: [Token]) {
//        self.tokens = tokens
//        self.variety = variety
//    }
//}
//
//extension Object {
//    enum Err: Error {
//        case invalidDirection(String)
//        case missingAttribute(String)
//        case missingName
//        case unconsumedTokens(String)
//        case unexpectedToken(String)
//    }
//
//    enum Variety: String {
//        case object = "Object"
//        case room   = "Room"
//
//        var dataType: Symbol.DataType {
//            switch self {
//            case .object: return .object
//            case .room:   return .room
//            }
//        }
//
//        var defType: Muddle.DefType {
//            switch self {
//            case .object: return .object
//            case .room:   return .room
//            }
//        }
//    }
//}
//
//extension Object {
//    mutating func process() throws -> Muddle.Definition {
//        guard case .atom(let zilName) = tokens.shiftAtom() else {
//            throw Err.missingName
//        }
//        let objectName = zilName.lowerCamelCase
//        while let listItem = tokens.shift() {
//            guard case .list(var listTokens) = listItem else {
//                if case .commented = listItem {
//                    continue // ignore comments
//                }
//                throw Err.unexpectedToken("\(listItem) \(tokens)")
//            }
//            guard case .atom(let name) = listTokens.shiftAtom() else {
//                throw Err.missingAttribute("\(listTokens)")
//            }
//
//            if let definition = Definition(rawValue: name),
//               let symbol = try definition.process(tokens: listTokens)
//            {
//                symbols.append(symbol)
//            } else if variety == .room {
//                directions.append(try processDirection(name, dirTokens: listTokens))
//            }
//        }
//        guard tokens.isEmpty else {
//            throw Err.unconsumedTokens("\(objectName) \(self) \(tokens)")
//        }
//
//        if variety == .room {
//            let directionsList = directions
//                .codeValues
//                .joined(separator: ",\n")
//            symbols.append(.init(
//                code: """
//                directions: [
//                \(directionsList.indented()),
//                ]
//                """,
//                type: .array(.direction)
//            ))
//        }
//        symbols.sort()
//        symbols.insert(
//            .init(code: "name: \"\(objectName)\"", type: .string),
//            at: 0
//        )
//
//        let propertyList = symbols
//            .codeValues
//            .joined(separator: ",\n")
//        return .init(
//            symbol: Symbol(
//                code: """
//                    /// The `\(objectName)` (\(zilName)) \(variety.rawValue.lowercased()).
//                    var \(objectName) = \(variety.rawValue)(
//                    \(propertyList.indented())
//                    )
//                    """,
//                name: objectName,
//                type: variety.dataType
//            ),
//            defType: variety.defType,
//            isMutable: true
//        )
//    }
//
//    func processDirection(
//        _ direction: String,
//        dirTokens: [Token]
//    ) throws -> Symbol {
//        var tokens = dirTokens
//        let name = Direction.name(for: direction)
//
//        var condition: String?
//        var destination: String?
//        var message: String?
//        var perFunction: String?
//
//        while !tokens.isEmpty {
//            guard let token = tokens.shift() else {
//                throw Err.invalidDirection("\(direction)")
//            }
//            switch token {
//            case .atom("TO"):
//                guard let room = try tokens.shiftAtom()?.process().description else {
//                    throw Err.invalidDirection("\(direction)")
//                }
//                destination = room
//            case .atom("PER"):
//                guard let function = try tokens.shiftAtom()?.process().description else {
//                    throw Err.invalidDirection("\(direction)")
//                }
//                perFunction = function
//            case .atom("IF"):
//                guard let cond = try tokens.shiftAtom()?.process().description else {
//                    throw Err.invalidDirection("\(direction)")
//                }
//                condition = cond
//            case .atom("IS"):
//                guard case .atom(let cond) = tokens.shift() else {
//                    throw Err.invalidDirection("\(direction)")
//                }
//                condition?.append(".is\(cond.upperCamelCase)")
//            case .atom("ELSE"):
//                guard let elseMessage = try tokens.shift()?.process().description else {
//                    throw Err.invalidDirection("\(direction)")
//                }
//                message = elseMessage
//            case .atom("SORRY"):
//                guard case .string(let blockedMessage) = tokens.shift() else {
//                    throw Err.invalidDirection("\(direction)")
//                }
//                message = blockedMessage
//            case .string(let blockedMessage):
//                message = blockedMessage
//            default:
//                throw Err.unexpectedToken("\(token) \(dirTokens)")
//            }
//        }
//
//        if let destination = destination {
//            if let condition = condition {
//                if let message = message {
//                    let code = """
//                    .\(name): .conditionalElse(\(destination),
//                        if: \(condition),
//                        else: \(message)
//                    )
//                    """
//                    return .init(code: code, type: .direction)
//                }
//                return .init(
//                    code: ".\(name): .conditional(\(destination), if: \(condition))",
//                    type: .direction
//                )
//            }
//            return .init(
//                code: ".\(name): .to(\(destination))",
//                type: .direction
//            )
//        }
//
//        if let message = message {
//            return .init(
//                code: ".\(name): .blocked(\(message.quoted()))",
//                type: .direction
//            )
//        }
//
//        if let perFunction = perFunction {
//            return .init(
//                code: ".\(name): .per(\(perFunction))",
//                type: .direction
//            )
//        }
//
//        throw Err.invalidDirection("\(dirTokens)")
//    }
//}
