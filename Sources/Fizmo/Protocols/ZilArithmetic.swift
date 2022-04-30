//
//  ZilArithmetic.swift
//  Fizmo
//
//  Created by Chris Sessions on 4/21/22.
//

import Foundation

/// A protocol that contains functions corresponding to Zil's arithmetic functions.
///
public protocol ZilArithmetic {
    /// Returns `true` if the value of `self` is one, else returns `false`.
    var isOne: Bool { get }

    /// Returns `true` if the value of `self` is zero, else returns `false`.
    var isZero: Bool { get }

    /// Adds two or more values and returns the result.
    ///
    /// - Parameter values: One or more values to add.
    ///
    /// - Returns: The resulting value.
    static func add(_ values: Self...) -> Self

    /// Divides two or more values and returns the result.
    ///
    /// - Parameter values: One or more values to divide.
    ///
    /// - Returns: The resulting value.
    static func divide(_ values: Self...) -> Self

    /// Multiplies two or more values and returns the result.
    ///
    /// - Parameter values: One or more values to multiply.
    ///
    /// - Returns: The resulting value.
    static func multiply(_ values: Self...) -> Self

    /// Subtracts one or more values and returns the result.
    ///
    /// - Parameter values: One or more values to subtract.
    ///
    /// - Returns: The resulting value.
    static func subtract(_ values: Self...) -> Self

    /// Adds one or more values to `self` and returns the result.
    ///
    /// `add` mutates `self` during the operation.
    ///
    /// - Parameter others: One or more values to add to `self`.
    ///
    /// - Returns: The resulting value.
    mutating func add(_ others: Self...) -> Self

    /// Subtracts `1` from `self` and returns the result.
    ///
    /// `decrement` mutates `self` during the operation.
    ///
    /// - Returns: The resulting value.
    mutating func decrement() -> Self

    /// Divides `self` by one or more values and returns the result.
    ///
    /// `divide` mutates `self` during the operation.
    ///
    /// - Parameter others: One or more values to divide `self` by.
    ///
    /// - Returns: The resulting value.
    mutating func divide(_ others: Self...) -> Self

    /// Multiplies `self` by one or more values and returns the result.
    ///
    /// `multiply` mutates `self` during the operation.
    ///
    /// - Parameter others: One or more values to multiply `self` by.
    ///
    /// - Returns: The resulting value.
    mutating func multiply(_ others: Self...) -> Self

    /// Subtracts one or more values from `self` and returns the result.
    ///
    /// `subtract` mutates `self` during the operation.
    ///
    /// - Parameter others: One or more values to subtract from `self`.
    ///
    /// - Returns: The resulting value.
    mutating func subtract(_ others: Self...) -> Self
}

// MARK: - Default implementations

extension ZilArithmetic where Self == Int {
    public var isOne: Bool {
        self == 1
    }

    public var isZero: Bool {
        self == 0
    }

    public static func add(_ values: Self...) -> Self {
        values.reduce(0, +)
    }

    public static func divide(_ values: Self...) -> Self {
        switch values.count {
        case 0:
            return 0
        case 1:
            return values[0]
        default:
            return values[1...].reduce(values[0], /)
        }
    }

    public static func multiply(_ values: Self...) -> Self {
        values.reduce(1, *)
    }

    public static func subtract(_ values: Self...) -> Self {
        switch values.count {
        case 0:
            return 0
        case 1:
            return -values[0]
        default:
            return values[1...].reduce(values[0], -)
        }
    }

    public mutating func add(_ others: Self...) -> Self {
        self = others.reduce(self, +)
        return self
    }

    public mutating func decrement() -> Self {
        self -= 1
        return self
    }

    public mutating func divide(_ others: Self...) -> Self {
        self = others.reduce(self, /)
        return self
    }

    public mutating func multiply(_ others: Self...) -> Self {
        self = others.reduce(self, *)
        return self
    }

    public mutating func subtract(_ others: Self...) -> Self {
        guard !others.isEmpty else {
            self = -self
            return self
        }
        self = others.reduce(self, -)
        return self
    }
}

// MARK: - Conformances

extension Int: ZilArithmetic {}
