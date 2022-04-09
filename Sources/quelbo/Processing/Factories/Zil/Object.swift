//
//  Object.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/12/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// function.
    class Object: ZilFactory {
        override class var zilNames: [String] {
            ["OBJECT"]
        }

        override var parameters: Parameters {
            .twoOrMore(.property)
        }

        override var returnType: Symbol.DataType {
            .object
        }

//        override func process() throws -> Symbol {
//        }
    }
}
