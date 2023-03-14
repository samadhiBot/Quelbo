//
//  IfDebug.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/12/23.
//

import Foundation

extension Factories {
    class IfDebug: Factory {
        override class var zilNames: [String] {
            ["IF-DEBUG", "IF-DEBUGGING-VERBS"]
        }

        override func evaluate() throws -> Symbol {
            .false
        }

        override func process() throws -> Symbol {
            .emptyStatement
        }
    }
}
