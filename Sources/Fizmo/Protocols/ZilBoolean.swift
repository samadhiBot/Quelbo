//
//  ZilBoolean.swift
//  Fizmo
//
//  Created by Chris Sessions on 4/21/22.
//

import Foundation

/// A protocol that contains functions corresponding to Zil's boolean logic functions.
///
public protocol ZilBoolean {
    /// Returns `true` when `self` and *all* of the other values are `true`.
    ///
    /// - Parameter others: One or more values to evaluate against `self`.
    ///
    /// - Returns: Whether `self` and all of the other values evaluate to `true`.
    ///
    static func and(_ others: Self...) -> Bool

    /// Returns `true` when `self` or *any* of the other values are `true`.
    ///
    /// - Parameter others: One or more values to evaluate against `self`.
    ///
    /// - Returns: Whether `self` or any of the other values evaluate to `true`.
    ///
    static func or(_ others: Self...) -> Bool
}

// MARK: - Default implementations

extension ZilBoolean where Self == Bool {
    public static func and(_ values: Self...) -> Bool {
        values.reduce(true) { $0 && $1 }
    }

    public static func or(_ values: Self...) -> Bool {
        values.reduce(false) { $0 || $1 }
    }
}

// MARK: - Conformances

extension Bool: ZilBoolean {}
