//
//  Symbol+Identifier.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/30/22.
//

import Foundation

extension Symbol {
    /// A unique symbol identifier.
    struct Identifier: Hashable {
        let rawValue: String
    }
}

extension Symbol.Identifier: Comparable {
    static func < (lhs: Symbol.Identifier, rhs: Symbol.Identifier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Symbol.Identifier: CustomStringConvertible {
    var description: String {
        return rawValue
    }
}

extension Symbol.Identifier: ExpressibleByStringLiteral {
    typealias StringLiteralType = String

    init(stringLiteral value: String) {
        rawValue = value
    }
}
