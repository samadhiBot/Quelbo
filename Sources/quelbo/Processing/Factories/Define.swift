//
//  Define.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/5/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [DEFINE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.440mph5j49mp)
    /// function.
    class Define: Factory {
        override class var zilNames: [String] {
            ["DEFINE"]
        }

        var zilName: String!
        var definition: [Token] = []

        override func processTokens() throws {
            var tokens = tokens

            self.zilName = try findName(in: &tokens)
            self.definition = tokens
        }

        override func process() throws -> Symbol {
            let definitionName = zilName!.lowerCamelCase

            return .definition(
                id: definitionName,
                tokens: definition
            )
        }
    }
}
