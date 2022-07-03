//
//  GetValue.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [VALUE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4j8vrz3)
    /// function.
    class GetValue: ZMachineFactory {
        override class var zilNames: [String] {
            ["VALUE"]
        }

        override class var parameters: Parameters {
            .one(.unknown)
        }

        override func process() throws -> Symbol {
            let variable = try symbol(0)

            guard variable.isIdentifiable else {
                throw Error.illegalGetValueOnNonIdentifiable(variable)
            }

            return variable.with(code: variable.description)
        }
    }
}

// MARK: - Errors

extension Factories.GetValue {
    enum Error: Swift.Error {
        case illegalGetValueOnNonIdentifiable(Symbol)
    }
}
