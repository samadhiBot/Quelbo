//
//  InsertFile.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/20/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GLOBAL](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2szc72q)
    /// function.
    class InsertFile: ZilFactory {
        override class var zilNames: [String] {
            ["INSERT-FILE"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .one(.string)
        }

        override func process() throws -> Symbol {
            Symbol("// Insert file '\(try symbol(0).code)'", type: .comment)
        }
    }
}
