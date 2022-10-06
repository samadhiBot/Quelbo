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
    /// The set of command types that factories can translate.
    enum FactoryType {
        /// Translates an MDL built-in or ZIL library command used outside routine definitions.
        case mdl

        /// Translates a ZIL object property.
        case property

        /// Translates a Z-code built-in command used within a routine definition.
        case zCode
    }
}
