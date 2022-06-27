//
//  Symbol+Identifier.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/30/22.
//

import Foundation

extension Symbol {
    /// A unique symbol identifier.
    struct Identifier: ExpressibleByStringLiteral, Hashable {
        typealias StringLiteralType = String

        let stringLiteral: String

        static func id(_ value: String) -> Self {
            .init(stringLiteral: value)
        }
    }
}

// MARK: - Conformances

extension Symbol.Identifier: Comparable {
    static func < (lhs: Symbol.Identifier, rhs: Symbol.Identifier) -> Bool {
        lhs.stringLiteral < rhs.stringLiteral
    }
}

extension Symbol.Identifier: CustomStringConvertible {
    var description: String {
        return stringLiteral
    }
}
