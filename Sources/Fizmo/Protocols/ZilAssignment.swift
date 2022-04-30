//
//  ZilAssignment.swift
//  Fizmo
//
//  Created by Chris Sessions on 4/23/22.
//

import Foundation

/// A protocol that contains functions corresponding to Zil's value assignment functions.
/// 
public protocol ZilAssignment {
    /// Set the value of `self` to the specified value.
    ///
    /// - Parameter value: The value to set `self`.
    ///
    /// - Returns: The value to which `self` has just been set.
    mutating func set(to value: Self) -> Self
}

// MARK: - Default implementations

extension ZilAssignment {
    @discardableResult
    public mutating func set(to value: Self) -> Self {
        self = value
        return value
    }
}

// MARK: - Conformances

extension Int: ZilAssignment {}

extension String: ZilAssignment {}
