////
////  MapStop.swift
////  Quelbo
////
////  Created by Chris Sessions on 5/7/22.
////
//
//import Foundation
//
//extension Factories {
//    /// A symbol factory for the Zil
//    /// [MAPSTOP](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.243i4a2)
//    /// function.
//    class MapStop: Factory {
//        override class var zilNames: [String] {
//            ["MAPSTOP"]
//        }
//
//        override func processSymbols() throws {
//            try symbols.assert(
//                .haveCount(.exactly(1))
//            )
//        }
//
//        override func process() throws -> Symbol {
//            let value = symbols[0]
//
//            return .statement(
//                code: { _ in
//                    "mapStop(\(value.code))"
//                },
//                type: value.type,
//                returnHandling: .force
////                isReturnStatement: true
//            )
//        }
//    }
//}
