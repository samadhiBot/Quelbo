//
//  List.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/4/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LIST](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4iylrwe)
    /// function.
    class List: MuddleFactory {
        override class var zilNames: [String] {
            ["LIST"]
        }

//        override class var parameters: SymbolFactory.Parameters {
//            .oneOrMore(.zilElement)
//        }

        override func process() throws -> Symbol {
            Symbol(
                "[\(symbols.codeValues(.commaSeparated))]",
                type: elementsType,
                children: symbols
            )
        }
    }
}

extension Factories.List {
    var elementsType: Symbol.DataType {
        guard let type = symbols.map(\.type).common else {
            return .array(.zilElement)
        }
        return .array(type)
    }
}
