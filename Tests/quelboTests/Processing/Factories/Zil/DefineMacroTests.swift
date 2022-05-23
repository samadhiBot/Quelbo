//
//  DefineMacroTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/2/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DefineMacroTests: QuelboTests {
    let factory = Factories.DefineMacro.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("DEFMAC"))
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.206ipza
    func testIncreaseMacro() throws {
        let symbol = try factory.init([
            .atom("INC"),
            .list([
                .atom("ATM"),
                .string("OPTIONAL"),
                .list([
                    .atom("N"),
                    .decimal(1)
                ])
            ]),
            .form([
                .atom("FORM"),
                .atom("SET"),
                .local("ATM"),
                .form([
                    .atom("FORM"),
                    .atom("+"),
                    .form([
                        .atom("FORM"),
                        .atom("LVAL"),
                        .local("ATM")
                    ]),
                    .local("N")
                ])
            ])
        ]).process()

        let expected = Symbol(
            id: "inc",
            code: """
                @discardableResult
                /// The `inc` (INC) macro.
                func inc(atm: Int, n: Int = 1) -> Int {
                    var atm = atm
                    return atm.set(to: atm.add(n))
                }
                """,
            type: .int,
            category: .routines,
            children: [
                Symbol(
                    id: "atm",
                    code: "atm: Int",
                    type: .int,
                    meta: [
                        Symbol.MetaData.mutating(true)
                    ]
                ),
                Symbol(
                    id: "<List>",
                    code: "n: Int = 1",
                    type: .list,
                    children: [
                        Symbol("n", type: .int),
                        Symbol(
                            "1",
                            type: .int,
                            meta: [.isLiteral]
                        )
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("inc", category: .routines), expected)
    }

    // https://mdl-language.readthedocs.io/en/latest/17-macro-operations/#172-eval-macros
    func testDoubleMacro() throws {
        let symbol = try factory.init([
            .atom("DOUBLE"),
            .list([
                .quote(.atom("ANY"))
            ]),
            .form([
                .atom("FORM"),
                .atom("PROG"),
                .list([
                    .list([
                        .atom("X"),
                        .local("ANY")
                    ])
                ]),
                .type("DECL"),
                .list([
                    .list([
                        .atom("X")
                    ]),
                    .atom("FIX")
                ]),
                .quote(.form([
                    .atom("+"),
                    .local("X"),
                    .local("X")
                ]))
            ])
        ]).process()

        let expected = Symbol(
            id: "double",
            code: """
                @discardableResult
                /// The `double` (DOUBLE) macro.
                func double() -> Int {
                    // Parameter `any` was specified but unused
                    return do {
                        var x: Int = any
                        return x.add(x)
                    }
                }
                """,
            type: .int,
            category: .routines,
            children: [
            ]
        )

        XCTAssertNoDifference(symbol, expected)
//        XCTAssertNoDifference(try Game.find("double", category: .routines), expected)
    }

//    func testBottlesMacro() throws {
//        let symbol = try factory.init([
//            .atom("BOTTLES"),
//            .list([
//                .quote(.atom("N"))
//            ]),
//            .form([
//                .atom("FORM"),
//                .atom("PROG"),
//                .quote(.list([
//                ])),
//                .form([
//                    .atom("FORM"),
//                    .atom("PRINTN"),
//                    .local("N")
//                ]),
//                .form([
//                    .atom("FORM"),
//                    .atom("PRINTI"),
//                    .string(" bottle")
//                ]),
//                .form([
//                    .atom("FORM"),
//                    .atom("COND"),
//                    .form([
//                        .atom("LIST"),
//                        .form([
//                            .atom("FORM"),
//                            .atom("N==?"),
//                            .local("N"),
//                            .decimal(1)
//                        ]),
//                        .quote(.form([
//                            .atom("PRINTC"),
//                            .character("s")
//                        ]))
//                    ])
//                ])
//            ])
//        ]).process()
//
//        let expected = Symbol(
//            id: "bottles",
//            code: """
//                /// The `bottles` (BOTTLES) macro.
//                func bottles(n: Int) {
//                    do {
//                        output(n)
//                        output(" bottle")
//                        if n.isNotEqualTo(1) {
//                            output("s")
//                        }
//                    }
//                }
//                """,
//            type: .void,
//            category: .routines,
//            children: [
//                Symbol(
//                    id: "n",
//                    code: "n: Int",
//                    type: .int
//                )
//            ]
//        )
//
//        XCTAssertNoDifference(symbol, expected)
////        XCTAssertNoDifference(try Game.find("bottles", category: .routines), expected)
//    }
}
