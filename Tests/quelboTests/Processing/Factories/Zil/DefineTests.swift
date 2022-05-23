//
//  DefineTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/5/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DefineTests: QuelboTests {
    let factory = Factories.Define.self
    let testFactory = TestFactory.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("DEFINE"))
    }

//    // https://mdl-language.readthedocs.io/en/latest/07-structured-objects/#755-form-and-iform
//    func testSimpleDefine() throws {
//        let symbol = try factory.init([
//            .atom("INC-FORM"),
//            .list([
//                .atom("A")
//            ]),
//            .form([
//                .atom("FORM"),
//                .atom("SET"),
//                .local("A"),
//                .form([
//                    .atom("FORM"),
//                    .atom("+"),
//                    .decimal(1),
//                    .form([
//                        .atom("FORM"),
//                        .atom("LVAL"),
//                        .local("A")
//                    ])
//                ])
//            ])
//        ]).process()
//
//        let expected = Symbol(
//            id: "incForm",
//            category: .definitions,
//            meta: [
//                .eval(
//                    .form([
//                        .atom("FUNCTION"),
//                        .list([
//                            .atom("A")
//                        ]),
//                        .form([
//                            .atom("FORM"),
//                            .atom("SET"),
//                            .local("A"),
//                            .form([
//                                .atom("FORM"),
//                                .atom("+"),
//                                .decimal(1),
//                                .form([
//                                    .atom("FORM"),
//                                    .atom("LVAL"),
//                                    .local("A")
//                                ])
//                            ])
//                        ])
//                    ])
//                )
//            ]
//        )
//
//        XCTAssertNoDifference(symbol, expected)
//        XCTAssertNoDifference(try Game.find("incForm", category: .definitions), expected)
//
//        let caller = try testFactory.init([
//            .form([
//                .atom("INC-FORM"),
//                .atom("FOO")
//            ])
//        ]).process()
//
//        XCTAssertNoDifference(caller, Symbol(
//            id: """
//                { (a: Int) -> Int in
//                    var a = a
//                    return a.set(to: .add(1, a))
//                }
//                """,
//            code: """
//                { (a: Int) -> Int in
//                    var a = a
//                    return a.set(to: .add(1, a))
//                }(foo)
//                """,
//            type: .int,
//            children: [
//                Symbol(
//                    id: "a",
//                    code: "foo",
//                    type: .int,
//                    meta: [.mutating(true)]
//                )
//            ]
//        ))
//    }

    // https://mdl-language.readthedocs.io/en/latest/17-macro-operations/#1722-example
    func testDefineWithDecl() throws {
        let symbol = try factory.init([
            .atom("DOUBLE"),
            .list([
                .atom("X")
            ]),
            .type("DECL"),
            .list([
                .list([
                    .atom("X")
                ]),
                .atom("FIX")
            ]),
            .form([
                .atom("+"),
                .local("X"),
                .local("X")
            ])
        ]).process()

        let expected = Symbol(
            id: "double",
            category: .definitions,
            meta: [
                .eval(
                    .form([
                        .atom("FUNCTION"),
                        .list([
                            .atom("X")
                        ]),
                        .type("DECL"),
                        .list([
                            .list([
                                .atom("X")
                            ]),
                            .atom("FIX")
                        ]),
                        .form([
                            .atom("+"),
                            .local("X"),
                            .local("X")
                        ])
                    ])
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("double", category: .definitions), expected)
        XCTAssertNil(try? Game.find("double", category: .routines))

        let caller = try testFactory.init([
            .form([
                .atom("DOUBLE"),
                .atom("FOO")
            ])
        ]).process()

        XCTAssertNoDifference(caller, Symbol(
            id: """
                { (x: Int) -> Int in
                    var x = x
                    return x.add(x)
                }
                """,
            code: """
                { (x: Int) -> Int in
                    var x = x
                    return x.add(x)
                }(foo)
                """,
            type: .int,
            children: [
                Symbol(
                    id: "x",
                    code: "foo",
                    type: .int
                )
            ]
        ))
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.440mph5j49mp
    func testPowerTo() throws {
        _ = try factory.init([
            .atom("POWER-TO"),
            .atom("ACT"),
            .list([
                .atom("X"),
                .string("OPT"),
                .list([
                    .atom("Y"),
                    .decimal(2)
                ])
            ]),
            .form([
                .atom("COND"),
                .list([
                    .form([
                        .atom("=?"),
                        .local("Y"),
                        .decimal(0)
                    ]),
                    .form([
                        .atom("RETURN"),
                        .decimal(1),
                        .local("ACT")
                    ])
                ])
            ]),
            .form([
                .atom("REPEAT"),
                .list([
                    .list([
                        .atom("Z"),
                        .decimal(1)
                    ]),
                    .list([
                        .atom("I"),
                        .decimal(0)
                    ])
                ]),
                .form([
                    .atom("SET"),
                    .atom("Z"),
                    .form([
                        .atom("*"),
                        .local("Z"),
                        .local("X")
                    ])
                ]),
                .form([
                    .atom("SET"),
                    .atom("I"),
                    .form([
                        .atom("+"),
                        .local("I"),
                        .decimal(1)
                    ])
                ]),
                .form([
                    .atom("COND"),
                    .list([
                        .form([
                            .atom("=?"),
                            .local("I"),
                            .local("Y")
                        ]),
                        .form([
                            .atom("RETURN"),
                            .local("Z")
                        ])
                    ])
                ])
            ])
        ]).process()

        let caller = try testFactory.init([
            .form([
                .atom("POWER-TO"),
                .decimal(2),
                .decimal(3),
            ])
        ]).process()

        XCTAssertNoDifference(caller.ignoringChildren, Symbol(
            id: """
                { (x: Int, y: Int = 2) -> Int in
                    if y.equals(0) {
                        return 1
                    }
                    var z: Int = 1
                    var i: Int = 0
                    while true {
                        z.set(to: z.multiply(x))
                        i.set(to: i.add(1))
                        if i.equals(y) {
                            return z
                        }
                    }
                }
                """,
            code: """
                { (x: Int, y: Int = 2) -> Int in
                    if y.equals(0) {
                        return 1
                    }
                    var z: Int = 1
                    var i: Int = 0
                    while true {
                        z.set(to: z.multiply(x))
                        i.set(to: i.add(1))
                        if i.equals(y) {
                            return z
                        }
                    }
                }(2, 3)
                """,
            type: .int
        ))
    }

//    func testFirstThree() throws {
//        let symbol = try factory.init([
//            .atom("FIRST-THREE"),
//            .list([
//                .atom("STRUC"),
//                .string("AUX"),
//                .list([
//                    .atom("I"),
//                    .decimal(3)
//                ])
//            ]),
//            .form([
//                .atom("MAPF"),
//                .global("LIST"),
//                .form([
//                    .atom("FUNCTION"),
//                    .list([
//                        .atom("E")
//                    ]),
//                    .form([
//                        .atom("COND"),
//                        .list([
//                            .form([
//                                .atom("0?"),
//                                .form([
//                                    .atom("SET"),
//                                    .atom("I"),
//                                    .form([
//                                        .atom("-"),
//                                        .local("I"),
//                                        .decimal(1)
//                                    ])
//                                ])
//                            ]),
//                            .form([
//                                .atom("MAPSTOP"),
//                                .local("E")
//                            ])
//                        ])
//                    ]),
//                    .local("E")
//                ]),
//                .local("STRUC")
//            ])
//        ]).process()
//
//        let expected = Symbol(
//            id: "firstThree",
//            category: .definitions,
//            meta: [
//                .eval(
//                    .form([
//                        .atom("FUNCTION"),
//
//                    ])
//                )
//            ]
//        )
//
//        XCTAssertNoDifference(symbol, expected)
//        XCTAssertNoDifference(try Game.find("firstThree", category: .definitions), expected)
//    }
//
//    func testMultifrob() throws {
//        let symbol = try factory.init([
//            .atom("MULTIFROB"),
//            .list([
//                .atom("X"),
//                .atom("ATMS"),
//                .string("AUX"),
//                .list([
//                    .atom("OO"),
//                    .list([
//                        .atom("OR")
//                    ])
//                ]),
//                .list([
//                    .atom("O"),
//                    .local("OO")
//                ]),
//                .list([
//                    .atom("L"),
//                    .list([
//                    ])
//                ]),
//                .atom("ATM")
//            ]),
//            .form([
//                .atom("REPEAT"),
//                .list([
//                ]),
//                .form([
//                    .atom("COND"),
//                    .list([
//                        .form([
//                            .atom("EMPTY?"),
//                            .local("ATMS")
//                        ]),
//                        .form([
//                            .atom("RETURN!-"),
//                            .form([
//                                .atom("COND"),
//                                .list([
//                                    .form([
//                                        .atom("LENGTH?"),
//                                        .local("OO"),
//                                        .decimal(1)
//                                    ]),
//                                    .form([
//                                        .atom("ERROR"),
//                                        .local("X")
//                                    ])
//                                ]),
//                                .list([
//                                    .form([
//                                        .atom("LENGTH?"),
//                                        .local("OO"),
//                                        .decimal(2)
//                                    ]),
//                                    .form([
//                                        .atom("NTH"),
//                                        .local("OO"),
//                                        .decimal(2)
//                                    ])
//                                ]),
//                                .list([
//                                    .atom("ELSE"),
//                                    .form([
//                                        .atom("CHTYPE"),
//                                        .local("OO"),
//                                        .atom("FORM")
//                                    ])
//                                ])
//                            ])
//                        ])
//                    ])
//                ]),
//                .form([
//                    .atom("REPEAT"),
//                    .list([
//                    ]),
//                    .form([
//                        .atom("COND"),
//                        .list([
//                            .form([
//                                .atom("EMPTY?"),
//                                .local("ATMS")
//                            ]),
//                            .form([
//                                .atom("RETURN!-")
//                            ])
//                        ])
//                    ]),
//                    .form([
//                        .atom("SET"),
//                        .atom("ATM"),
//                        .form([
//                            .atom("NTH"),
//                            .local("ATMS"),
//                            .decimal(1)
//                        ])
//                    ]),
//                    .form([
//                        .atom("SET"),
//                        .atom("L"),
//                        .list([
//                            .form([
//                                .atom("COND"),
//                                .list([
//                                    .form([
//                                        .atom("TYPE?"),
//                                        .local("ATM"),
//                                        .atom("ATOM")
//                                    ]),
//                                    .form([
//                                        .atom("FORM"),
//                                        .atom("GVAL"),
//                                        .form([
//                                            .atom("COND"),
//                                            .list([
//                                                .form([
//                                                    .atom("==?"),
//                                                    .local("X"),
//                                                    .atom("PRSA")
//                                                ]),
//                                                .form([
//                                                    .atom("PARSE"),
//                                                    .form([
//                                                        .atom("STRING"),
//                                                        .string("V?"),
//                                                        .form([
//                                                            .atom("SPNAME"),
//                                                            .local("ATM")
//                                                        ])
//                                                    ])
//                                                ])
//                                            ]),
//                                            .list([
//                                                .atom("ELSE"),
//                                                .local("ATM")
//                                            ])
//                                        ])
//                                    ])
//                                ]),
//                                .list([
//                                    .atom("ELSE"),
//                                    .local("ATM")
//                                ])
//                            ]),
//                            .segment(.local("L"))
//                        ])
//                    ]),
//                    .form([
//                        .atom("SET"),
//                        .atom("ATMS"),
//                        .form([
//                            .atom("REST"),
//                            .local("ATMS")
//                        ])
//                    ]),
//                    .form([
//                        .atom("COND"),
//                        .list([
//                            .form([
//                                .atom("==?"),
//                                .form([
//                                    .atom("LENGTH"),
//                                    .local("L")
//                                ]),
//                                .decimal(3)
//                            ]),
//                            .form([
//                                .atom("RETURN!-")
//                            ])
//                        ])
//                    ])
//                ]),
//                .form([
//                    .atom("SET"),
//                    .atom("O"),
//                    .form([
//                        .atom("REST"),
//                        .form([
//                            .atom("PUTREST"),
//                            .local("O"),
//                            .list([
//                                .form([
//                                    .atom("FORM"),
//                                    .atom("EQUAL?"),
//                                    .form([
//                                        .atom("FORM"),
//                                        .atom("GVAL"),
//                                        .local("X")
//                                    ]),
//                                    .segment(.local("L"))
//                                ])
//                            ])
//                        ])
//                    ])
//                ]),
//                .form([
//                    .atom("SET"),
//                    .atom("L"),
//                    .list([
//                    ])
//                ])
//            ])
//        ]).process()
//
//        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
//            id: "multifrob",
//            code: """
//                /// The `multifrob` (MULTIFROB) function.
//                func multifrob(
//                    x: <Unknown>,
//                    atms: <Unknown>
//                ) {
//                    var atm: <Unknown> = ???
//                    var atms = atms
//                    var oo: <List> =
//                    var o: <Unknown> = oo
//                    var l: <List> =
//                    while true {
//                        if atms.isEmpty {
//                            return if oo.count == 1 {
//                                throw FizmoError.mdlError(x
//                            } else if oo.count == 2 {
//                                oo.nthElement(2)
//                            } else {
//                                oo.changeType(form)
//                            }
//                        }
//                        while true {
//                            if atms.isEmpty {
//                                break
//                            }
//                            atm.set(to: atms.nthElement(1))
//                            l.set(to: )
//                            atms.set(to: atms.rest())
//                            if l.count.equals(3) {
//                                break
//                            }
//                        }
//                        o.set(to: o.putRest().rest())
//                        l.set(to: )
//                    }
//                }
//                """,
//            type: .void,
//            category: .definitions
//        ))
//    }
//
}
