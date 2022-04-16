//
//  Get.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GET](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.r2r73f)
    /// function.
    class Get: ZMachineFactory {
        override class var zilNames: [String] {
            ["GET"]
        }

        override class var parameters: Parameters {
            .two(.array(.tableElement), .int)
        }

        override class var returnType: Symbol.DataType {
            .tableElement
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0))[\(try symbol(1))]",
                type: .tableElement,
                children: symbols
            )
        }
    }
}
