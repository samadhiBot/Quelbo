//
//  MapStop.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [MAPSTOP](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.243i4a2)
    /// function.
    class MapStop: MuddleFactory {
        override class var zilNames: [String] {
            ["MAPSTOP"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .one(.unknown)
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0).code).mapStop",
                type: .bool,
                children: symbols
            )
        }
    }
}
