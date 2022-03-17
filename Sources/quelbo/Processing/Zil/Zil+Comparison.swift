//
//  Zil+Comparison.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/13/22.
//

import Foundation
import SwiftUI

extension Zil {
    struct Comparison {
        let operation: String
        var tokens: [Token]

        init(_ operation: String, _ tokens: [Token]) {
            self.operation = operation
            self.tokens = tokens
        }
    }
}

extension Zil.Comparison {
    enum Err: Error {
        case missingLeftComparator(String)
        case missingRightComparator(String)
    }

    mutating func process() throws -> String {
        guard let left = try tokens.shift()?.process() else {
            throw Err.missingLeftComparator("\(tokens)")
        }
        guard let right = try tokens.shift()?.process() else {
            throw Err.missingRightComparator("\(tokens)")
        }
        return "\(left) \(operation) \(right)"
    }
}
