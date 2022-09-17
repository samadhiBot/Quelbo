//
//  TypeInfo+Confidence.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/12/22.
//

import Foundation

// MARK: - TypeInfo.Confidence

extension TypeInfo {
    enum Confidence: Int {
        case unknown
        case void
        case booleanFalse
        case integerZero
        case assured
        case booleanTrue
        case scoped
        case certain
    }
}

extension TypeInfo.Confidence: Comparable {
    static func < (lhs: TypeInfo.Confidence, rhs: TypeInfo.Confidence) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

