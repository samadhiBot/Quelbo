//
//  ChangeType.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [CHTYPE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2grqrue)
    /// function.
    class ChangeType: Factory {
        override class var zilNames: [String] {
            ["CHTYPE"]
        }

        /*
         PRIMTYPE
         <PRIMTYPE value>

         MDL built-in

         evaluates to the primitive type of value. The primitive types are  ATOM, FIX, LIST, STRING, TABLE and VECTOR.
         Examples:
         <PRIMTYPE !\A>        -->     FIX
         <PRIMTYPE <+1 2>>    -->     FIX
         <PRIMTYPE "ABC">    -->     STRING

         */

        /*
         TYPEPRIM
         <TYPEPRIM type>

         MDL built-in

         evaluates to the primitive type of type. The primitive types are  ATOM, FIX, LIST, STRING, TABLE and VECTOR.
         Examples:
         <TYPEPRIM CHARACTER>        -->     FIX
         <TYPEPRIM FORM>            -->     LIST
         <TYPEPRIM BYTE>            -->     FIX

         */

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(2)))

            try symbols[1].assert(.hasType(.string))
        }

        override func process() throws -> Symbol {
            let value = symbols[0]
            let newType = symbols[1]

            return .statement(
                code: { _ in
                    "\(value.code).changeType(.\(newType.code))"
                },
                type: try dataType(for: newType.code),
                confidence: .certain
            )
        }
    }
}

extension Factories.ChangeType {
    func dataType(for code: String) throws -> DataType {
        switch code {
        case "fix": return .int
        case "form": return .unknown
        case "string": return .string
        default: throw Error.unimplementedChangeType(code)
        }
    }
}

// MARK: - Errors

extension Factories.ChangeType {
    enum Error: Swift.Error {
        case unimplementedChangeType(String)
    }
}
