//
//  Constant.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/1/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [CONSTANT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3tbugp1)
    /// function.
    class Constant: Global {
        override class var zilNames: [String] {
            ["CONSTANT"]
        }

        required init(
            _ tokens: [Token],
            in blockType: SymbolFactory.ProgramBlockType? = nil,
            with types: SymbolFactory.TypeRegistry? = nil
        ) throws {
            try super.init(tokens, with: types)
            isMutable = false
        }
    }
}
