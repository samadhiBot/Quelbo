//
//  Game+Factories.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

extension Game {
    /// ``Symbol`` factories for translating ZIL Object properties.
    static let zilPropertyFactories = _Runtime.subclasses(of: ZilPropertyFactory.self)
        .map { $0 as! SymbolFactory.Type }

    /// ``Symbol`` factories for translating root-level ZIL functions.
    static let zilSymbolFactories = _Runtime.subclasses(of: ZilFactory.self)
        .map { $0 as! SymbolFactory.Type }

    /// ``Symbol`` factories for translating routine-level Z-Machine built-in functions.
    static let zMachineSymbolFactories = _Runtime.subclasses(of: ZMachineFactory.self)
        .map { $0 as! SymbolFactory.Type }
}
