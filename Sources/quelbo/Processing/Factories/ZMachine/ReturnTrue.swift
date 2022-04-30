//
//  ReturnTrue.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [RTRUE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4e4bwxm)
    /// function.
    class ReturnTrue: ZMachineFactory {
        override class var zilNames: [String] {
            ["RTRUE"]
        }

        override class var parameters: Parameters {
            .zero
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        override func process() throws -> Symbol {
            Symbol(
                id: "<Return>",
                code: "return true",
                type: .bool,
                children: [.trueSymbol]
            )
        }
    }
}
