//
//  DeclareType.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the MDL
    /// [#DECL](https://mdl-language.readthedocs.io/en/latest/14-data-type-declarations/#143-the-decl-syntax)
    /// and
    /// [GDECL](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.k62wjra3zbsy)
    /// type declarations.
    class DeclareType: Factory {
        override class var zilNames: [String] {
            ["#DECL", "GDECL"]
        }

        override func processTokens() throws {
            // Don't process tokens. In practice, Zil's type declarations don't provide anything
            // beyond what Quelbo can otherwise infer during type discovery.
        }

        override func process() throws -> Symbol {
            .statement(
                code: { _ in "" },
                type: .comment
            )
        }
    }
}
