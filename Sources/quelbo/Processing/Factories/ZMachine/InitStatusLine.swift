//
//  InitStatusLine.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/20/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [INIT-STATUS-LINE](https://archive.org/details/Learning_ZIL_Steven_Eric_Meretzky_1995/page/n63/mode/1up)
    /// function.
    class InitStatusLine: ZMachineFactory {
        override class var zilNames: [String] {
            ["INIT-STATUS-LINE"]
        }

        override class var returnType: Symbol.DataType {
            .void
        }

        override func process() throws -> Symbol {
            Symbol("initStatusLine()", type: .void)
        }
    }
}
