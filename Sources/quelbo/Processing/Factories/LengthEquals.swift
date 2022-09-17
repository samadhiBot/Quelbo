//
//  LengthEquals.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LENGTH?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.zu0gcz)
    /// function.
    class LengthEquals: Factory {
        override class var zilNames: [String] {
            ["LENGTH?"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(2)))

            try symbols[0].assertHasType(
                .array(.unknown)
            )
            try symbols[1].assert(.hasType(.int))
        }
        
        override func process() throws -> Symbol {
            let container = symbols[0]
            let length = symbols[1]

//            guard case .array = container.type else {
//                throw Error.lengthEqualsExpectedArray(container)
//            }

            return .statement(
                code: { _ in
                    "\(container.code).count == \(length.code)"
                },
                type: .bool
            )
        }
    }
}

//// MARK: - Errors
//
//extension Factories.LengthEquals {
//    enum Error: Swift.Error {
//        case lengthEqualsExpectedArray(Symbol)
//    }
//}
