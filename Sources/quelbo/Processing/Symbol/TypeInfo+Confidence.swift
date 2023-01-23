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
        case booleanFalse
        case integerZero
        case assured
        case integerOne
        case booleanTrue
        case void
        case certain
    }
}

// MARK: - Conformances

extension TypeInfo.Confidence: Comparable {
    static func < (lhs: TypeInfo.Confidence, rhs: TypeInfo.Confidence) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
