//
//  Zil+Process.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/25/22.
//

import Foundation

extension Zil {
    // https://bit.ly/3tYr7PQ
    func add(_ tokens: [Token]) throws -> String {
        let Worldment = try tokens.map { try $0.process() }
            .joined(separator: " + ")
        return "(\(Worldment))"
    }

    // https://bit.ly/3q2LqdQ
    func and(_ tokens: [Token]) throws -> String {
        try tokens.map {
            try $0.process()
        }
        .joined(separator: " && ")
    }

    // https://bit.ly/3KHsFVo
    func clearFlag(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let object = try tokens.shiftAtom()?.process() else {
            throw Err.missingObject("clearFlag \(tokens)")
        }
        guard var property = try tokens.shiftAtom()?.process() else {
            throw Err.missingProperty("clearFlag \(object)")
        }
        if property.hasPrefix("World.") {
            property.removeFirst(6)
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("clearFlag \(object) \(property) \(tokens)")
        }
        return "\(object).\(property) = false"
    }

    // https://bit.ly/36el7dI
    func condition(_ tokens: [Token]) throws -> String {
        var condition = Zil.Condition(tokens)
        return try condition.process()
    }

    // https://bit.ly/3CLu6zd
    func crlf(_ tokens: [Token]) throws -> String {
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("crlf \(tokens)")
        }
        return "tell(carriageReturn)"
    }

    func decrementLessThan(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let name = try tokens.shiftAtom()?.process() else {
            throw Err.missingName("decrementLessThan \(tokens)")
        }
        guard let value = try tokens.shift()?.process() else {
            throw Err.missingValue("decrementLessThan \(name)")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("decrementLessThan \(name) \(value) \(tokens)")
        }
        return "\(name).decrement() < \(value)"
    }

    // https://bit.ly/3CNupcT
    func divide(_ tokens: [Token]) throws -> String {
        try tokens.map {
            try $0.process()
        }
        .joined(separator: " / ")
    }

    // https://bit.ly/3q7uzGY
    func get(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let table = try tokens.shift()?.process() else {
            throw Err.missingTable("get \(tokens)")
        }
        guard let value = try tokens.shift()?.process() else {
            throw Err.missingValue("get \(table)")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("get \(table) \(value) \(tokens)")
        }
        return "\(table)[\(value)]"
    }

    // https://bit.ly/36kF7eD
    func getProperty(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let object = try tokens.shiftAtom()?.process() else {
            throw Err.missingObject("getProperty \(tokens)")
        }
        guard let property = try tokens.shiftAtom()?.process() else {
            throw Err.missingProperty("getProperty \(object)")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("getProperty \(object) \(property) \(tokens)")
        }
        return "\(object).\(property)"
    }

    // https://bit.ly/3qbpMV5
    func isEqualTo(_ tokens: [Token]) throws -> String {
        var comparison = Comparison("==", tokens, multiCondition: "contains")
        return try comparison.process()
    }

    // https://bit.ly/3qcdgVd
    func isGreaterThan(_ tokens: [Token]) throws -> String {
        var comparison = Comparison(">", tokens)
        return try comparison.process()
    }

    // https://bit.ly/3KW2V7X
    func isGreaterThanOrEqualTo(_ tokens: [Token]) throws -> String {
        var comparison = Comparison(">=", tokens)
        return try comparison.process()
    }

    // https://bit.ly/3weaB1d
    func isLessThan(_ tokens: [Token]) throws -> String {
        var comparison = Comparison("<", tokens)
        return try comparison.process()
    }

    // https://bit.ly/3MZXaHS
    func isLessThanOrEqualTo(_ tokens: [Token]) throws -> String {
        var comparison = Comparison("<=", tokens)
        return try comparison.process()
    }

    // https://bit.ly/36Kc3gQ
    func isNotEqualTo(_ tokens: [Token]) throws -> String {
        var comparison = Comparison("!=", tokens, multiCondition: "allSatisfy")
        return try comparison.process()
    }

    // https://bit.ly/3u7eMZO
    func isOne(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let value = try tokens.shift()?.process() else {
            throw Err.missingValue("isOne")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("isOne \(value) \(tokens)")
        }
        return "\(value) == 1"
    }

    // https://bit.ly/3JvLLgM
    func isZero(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let value = try tokens.shift()?.process() else {
            throw Err.missingValue("isZero")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("isZero \(value) \(tokens)")
        }
        return "\(value) == 0"
    }

    // https://bit.ly/3KNQElY
    func move(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let object = try tokens.shiftAtom()?.process() else {
            throw Err.missingName("move \(tokens)")
        }
        guard let destination = try tokens.shift()?.process() else {
            throw Err.missingValue("move \(object)")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("move \(object) \(destination) \(tokens)")
        }
        return "move(\(object), to: \(destination))"
    }

    // https://bit.ly/35W6HiG
    func multiply(_ tokens: [Token]) throws -> String {
        try tokens.map {
            try $0.process()
        }
        .joined(separator: " * ")
    }

    // https://bit.ly/3idmZpK
    func or(_ tokens: [Token]) throws -> String {
        try tokens.map { try $0.process() }
            .joined(separator: " || ")
    }

    // https://bit.ly/3wCUGcR
    func printCharacter(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let char = tokens.shift() else {
            throw Err.missingValue("printCharacter \(tokens)")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("printCharacter \(char) \(tokens)")
        }
        switch char {
        case .atom:
            return "output(\(try char.process()))"
        case .decimal(let value):
            guard let scaler = UnicodeScalar(value) else {
                throw Err.invalidValue("printCharacter \(char)")
            }
            return "output(\"\(Character(scaler))\")"
        default:
            throw Err.invalidValue("\(char)")
        }
    }

    // https://bit.ly/3Nidggt
    func printDescription(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let object = try tokens.shiftAtom()?.process() else {
            throw Err.missingValue("printDescription \(tokens)")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("printDescription \(object) \(tokens)")
        }
        return "output(\(object).description)"
    }

    // https://bit.ly/3NpxYuA
    func print(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let value = try tokens.shift()?.process() else {
            throw Err.missingValue("print \(tokens)")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("print \(value) \(tokens)")
        }
        return "output(\(value))"
    }

    // https://bit.ly/3qByGv9
    func printStringCR(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let value = try tokens.shift()?.process() else {
            throw Err.missingValue("print \(tokens)")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("print \(value) \(tokens)")
        }
        return """
            output(
            \(value.indented()),
                withCarriageReturn: true
            )
            """
    }

    // https://bit.ly/36JZZMH
    func printTable(_ tokens: [Token]) throws -> String {
        throw Err.unimplemented("printTable \(tokens)")
    }

    // https://bit.ly/3u72Kj1
    func programBlock(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        _ = tokens.shiftList() // programBlock params are unused in Zork 1
        let code = try tokens.map { try $0.process() }
            .joined(separator: "\n")
            .indented()
        return """
        do {
        \(code)
        }
        """
    }

    // https://bit.ly/3u3356m
    func putProperty(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let object = try tokens.shiftAtom()?.process() else {
            throw Err.missingObject("putProperty \(tokens)")
        }
        guard let property = try tokens.shiftAtom()?.process() else {
            throw Err.missingProperty("putProperty \(object) \(tokens)")
        }
        guard let value = try tokens.shift()?.process() else {
            throw Err.missingValue("putProperty \(object).\(property) \(tokens)")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("putProperty \(object) \(property) \(value) \(tokens)")
        }
        return "\(object).\(property) = \(value)"
    }

    // https://bit.ly/3CFHvcj
    func `repeat`(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        _ = tokens.shiftList() // repeat params are unused in Zork 1
        let code = try tokens.map { try $0.process() }
            .joined(separator: "\n")
            .indented()
        return """
        repeat {
        \(code)
        } while true
        """
    }

    // https://bit.ly/3w7hP6P
    func returnFalse(_ tokens: [Token]) throws -> String {
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("returnFalse")
        }
        return "return false"
    }

    // https://bit.ly/3MSqMHp
    func returnTrue(_ tokens: [Token]) throws -> String {
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("returnTrue")
        }
        return "return true"
    }

    // https://bit.ly/36hyzxi
    func set(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let name = try tokens.shiftAtom()?.process() else {
            throw Err.missingName("set \(tokens)")
        }
        guard let value = try tokens.shift()?.process() else {
            throw Err.missingValue("set \(name)")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("set \(name) \(value) \(tokens)")
        }
        return "set(&\(name), to: \(value))"
    }

    // https://bit.ly/3KGYs8S
    func setFlag(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let object = try tokens.shiftAtom()?.process() else {
            throw Err.missingObject("setFlag \(tokens)")
        }
        guard var property = try tokens.shiftAtom()?.process() else {
            throw Err.missingProperty("setFlag \(object)")
        }
        if property.hasPrefix("World.") {
            property.removeFirst(6)
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("setFlag \(object) \(property) \(tokens)")
        }
        return "\(object).\(property) = true"
    }

    // https://bit.ly/36iLDCC
    func setGlobal(_ tokens: [Token]) throws -> String {
        var tokens = tokens
        guard let name = try tokens.shiftAtom()?.process() else {
            throw Err.missingName("setGlobal \(tokens)")
        }
        guard let value = try tokens.shift()?.process() else {
            throw Err.missingValue("setGlobal \(name)")
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("setGlobal \(name) \(value) \(tokens)")
        }
        return "World.\(name) = \(value)"
    }

    // https://bit.ly/3I4mWXP
    func subtract(_ tokens: [Token]) throws -> String {
        if tokens.count == 1 {
            return "-\(try tokens[0].process())"
        } else {
            let Worldment = try tokens.map { try $0.process() }
                .joined(separator: " - ")
            return "(\(Worldment))"
        }
    }

    // https://bit.ly/3J8sxxV
    func tell(_ tokens: [Token]) throws -> String {
        var describe = false
        let values = try tokens.compactMap { (token: Token) -> String? in
            if case .atom("D") = token {
                describe = true
                return nil
            }
            let element = try token.process()
            if describe {
                describe = false
                return "\(element).description"
            } else {
                return element
            }
        }

        if tokens.count > 1 {
            return """
                tell(
                \(values.joined(separator: ",\n").indented())
                )
                """
        }
        return "tell(\(values))"
    }
}
