//
//  TypeInfo+Confidence.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/12/22.
//

import Foundation

extension TypeInfo {
    enum Confidence: Int {
        case none
        case limited
        case void
        case booleanFalse
        case integerZero
        case assured
        case booleanTrue
        case certain
    }
}

// MARK: - Conformances

extension TypeInfo.Confidence: Comparable {
    static func < (lhs: TypeInfo.Confidence, rhs: TypeInfo.Confidence) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
