//
//  ZilComparable.swift
//  Fizmo
//
//  Created by Chris Sessions on 4/21/22.
//

import Foundation

/// A protocol that contains functions corresponding to Zil's comparison functions.
///
public protocol ZilComparable {
    /// Returns `true` if a value is equal to each of the other specified values.
    ///
    /// - Parameter others: One or more values to compare against.
    ///
    /// - Returns: Whether `self` is equal to all of the specified values.
    ///
    func equals(_ others: Self...) -> Bool

    /// Returns `true` if a value is greater than each of the other specified values.
    ///
    /// - Parameter others: One or more values to compare against.
    ///
    /// - Returns: Whether `self` is greater than each of the specified values.
    ///
    func isGreaterThan(_ others: Self...) -> Bool

    /// Returns `true` if a value is greater than or equal to each of the other specified values.
    ///
    /// - Parameter others: One or more values to compare against.
    ///
    /// - Returns: Whether `self` is greater than or equal to each of the specified values.
    ///
    func isGreaterThanOrEqualTo(_ others: Self...) -> Bool

    /// Returns `true` if a value is less than each of the other specified values.
    ///
    /// - Parameter others: One or more values to compare against.
    ///
    /// - Returns: Whether `self` is less than each of the specified values.
    ///
    func isLessThan(_ others: Self...) -> Bool

    /// Returns `true` if a value is less than or equal to each of the other specified values.
    ///
    /// - Parameter others: One or more values to compare against.
    ///
    /// - Returns: Whether `self` is less than or equal to each of the specified values.
    ///
    func isLessThanOrEqualTo(_ others: Self...) -> Bool

    /// Returns `true` if a value is not equal to any of the other specified values.
    ///
    /// - Parameter others: One or more values to compare against.
    ///
    /// - Returns: Whether `self` is not equal to any of the specified values.
    ///
    func isNotEqualTo(_ others: Self...) -> Bool
}

// MARK: - Default implementations

extension ZilComparable where Self: Comparable {
    public func equals(_ others: Self...) -> Bool {
        others.allSatisfy { other in
            self == other
        }
    }

    public func isGreaterThan(_ others: Self...) -> Bool {
        others.allSatisfy { other in
            self > other
        }
    }

    public func isGreaterThanOrEqualTo(_ others: Self...) -> Bool {
        others.allSatisfy { other in
            self >= other
        }
    }

    public func isLessThan(_ others: Self...) -> Bool {
        others.allSatisfy { other in
            self < other
        }
    }

    public func isLessThanOrEqualTo(_ others: Self...) -> Bool {
        others.allSatisfy { other in
            self <= other
        }
    }

    public func isNotEqualTo(_ others: Self...) -> Bool {
        others.allSatisfy { other in
            self != other
        }
    }
}

// MARK: - Conformances

extension Int: ZilComparable {}

extension String: ZilComparable {}
