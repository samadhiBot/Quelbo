//
//  Factories.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

/// Namespace for symbol factories that translate a ``Token`` array to a ``Symbol`` array.
enum Factories {}

// MARK: - FactoryError

enum FactoryError: Error {
    case unimplemented(SymbolFactory)
}
