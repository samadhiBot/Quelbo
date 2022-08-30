//
//  DataType+Confidence.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/12/22.
//

import Foundation

// MARK: - DataType.Confidence

extension DataType {
    enum Confidence: Int {
        case unknown
        case void
        case booleanFalse
        case integerZero
        case assured
        case booleanTrue
        case certain
    }
}

extension DataType.Confidence: Comparable {
    static func < (lhs: DataType.Confidence, rhs: DataType.Confidence) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
