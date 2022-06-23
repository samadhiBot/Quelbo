//
//  Function.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [FUNCTION](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.m3e5asphu6rd)
    /// function.
    class Function: MuddleFactory {
        override class var zilNames: [String] {
            ["FUNCTION"]
        }

        var pro: BlockProcessor!

        override func processTokens() throws {
            self.pro = try BlockProcessor(tokens, in: .blockWithDefaultActivation, with: registry)
        }

        override func process() throws -> Symbol {
            let argNames = pro.paramsSymbol.children.codeValues(.commaSeparated)
            let argTypes = pro.paramsSymbol.children
                .map { $0.type.description }
                .joined(separator: ", ")

            return Symbol(
                """
                    {\(argNames.isEmpty ? "" : " (\(argNames))\(pro.returnValue) in")
                    \(pro.warningComments(indented: true))\
                    \(pro.auxiliaryDefs(indented: true))\
                    \(pro.codeBlock.indented)
                    }
                    """,
                type: pro.type,
                children: pro.paramsSymbol.children,
                meta: [
                    .mutating(false),
                    .type("(\(argTypes))\(pro.returnValue)"),
                ]
            )
        }
    }
}
