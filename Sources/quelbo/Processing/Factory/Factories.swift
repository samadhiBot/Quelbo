//
//  Factories.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/1/22.
//

import Foundation

/// Namespace for symbol factories that translate a ``Token`` array to a ``Symbol`` array.
enum Factories {}

// MARK: - Factory.FactoryType

extension Factories {
    /// Represents the different factory types.
    ///
    /// Used for disambiguation in cases when a ZIL statement behaves differently depending on the
    /// context, and therefore might have multiple factories in Quelbo.
    enum FactoryType {
        /// Translates an MDL built-in or ZIL library command used outside routine definitions.
        case mdl

        /// Translates a ZIL object property.
        case property

        /// Translates a Z-code built-in command used within a routine definition.
        case zCode
    }
}
