//
//  IsGreaterThan.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GRTR?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3ws6mnt)
    /// function.
    class IsGreaterThan: Equals {
        override class var zilNames: [String] {
            ["G?", "GRTR?"]
        }

        override var function: String {
            "isGreaterThan"
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(2)),
                .haveType(.int)
            )
        }

        func comparisonEval(_ first: Int, _ second: Int) -> Bool {
            first > second
        }

        override func evaluate() throws -> Symbol {
            guard let firstElement = symbols.first?.evaluation else {
                return .false
            }
            guard let firstInt = firstElement.intValue else {
                throw Error.invalidLiteralComparison(firstElement)
            }
            for element in symbols.nonCommentSymbols[1..<symbols.count].compactMap(\.evaluation) {
                guard let elementInt = element.intValue else {
                    throw Error.invalidLiteralComparison(element)
                }
                guard comparisonEval(firstInt, elementInt) else { return .false }
            }
            return .true
        }
    }
}


// MARK: - Errors

extension Factories.IsGreaterThan {
    enum Error: Swift.Error {
        case invalidLiteralComparison(Literal)
    }
}
