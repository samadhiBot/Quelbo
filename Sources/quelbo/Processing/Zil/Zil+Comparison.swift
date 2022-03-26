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
        var multiCondition: String?

        init(
            _ operation: String,
            _ tokens: [Token],
            multiCondition: String? = nil
        ) {
            self.operation = operation
            self.tokens = tokens
            self.multiCondition = multiCondition
        }
    }
}

extension Zil.Comparison {
    enum Err: Error {
        case invalidMultiComparison
        case missingLeftComparator(String)
        case missingRightComparator(String)
    }

    mutating func process() throws -> String {
        guard let left = try tokens.shift()?.process() else {
            throw Err.missingLeftComparator("\(tokens)")
        }
        let rightComparators = try tokens.map { try $0.process() }
        guard !rightComparators.isEmpty else {
            throw Err.missingRightComparator("\(tokens)")
        }
        if rightComparators.count == 1 {
            return "\(left) \(operation) \(rightComparators[0])"
        }
        guard let multiCondition = multiCondition else {
            throw Err.invalidMultiComparison
        }
        let right = rightComparators.joined(separator: ", ")
        return "[\(right)].\(multiCondition) { \(left) \(operation) $0 }"
    }
}
