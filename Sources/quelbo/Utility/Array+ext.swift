//
//  Array+ext.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/8/22.
//

import Foundation

extension Array {
    /// Safely shifts an `Element` from the front of an `Array`.
    ///
    /// - Returns: The first `Element` of the `Array`. Returns `nil` if the array is empty.
    mutating func shift() -> Element? {
        guard !isEmpty else { return nil }
        return removeFirst()
    }
}

extension Array where Element == Token {
    /// Safely shifts an `.atom` from the front of an `Array` of `Tokens`.
    ///
    /// - Returns: The first `.atom` of the `Array`. Returns `nil` if the array is empty, or the
    ///            first `Token` in the array is not an `.atom`.
    mutating func shiftAtom() -> Token? {
        guard !isEmpty, case .atom = first else { return nil }
        return removeFirst()
    }

    /// Safely shifts a `.list` from the front of an `Array` of `Tokens`.
    ///
    /// - Returns: The first `.list` of the `Array`. Returns `nil` if the array is empty, or the
    ///            first `Token` in the array is not an `.list`.
    mutating func shiftList() -> Token? {
        guard !isEmpty, case .list = first else { return nil }
        return removeFirst()
    }
}
