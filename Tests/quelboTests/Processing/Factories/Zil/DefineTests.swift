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

    // https://mdl-language.readthedocs.io/en/latest/07-structured-objects/#755-form-and-iform
    func testSimpleDefine() throws {
        let symbol = try factory.init([
            .atom("INC-FORM"),
            .list([
                .atom("A")
            ]),
            .form([
                .atom("FORM"),
                .atom("SET"),
                .local("A"),
                .form([
                    .atom("FORM"),
                    .atom("+"),
                    .decimal(1),
                    .form([
                        .atom("FORM"),
                        .atom("LVAL"),
                        .local("A")
                    ])
                ])
            ])
        ]).process()

        let expected = Symbol(
            id: "incForm",
            code: """
                @discardableResult
                /// The `incForm` (INC-FORM) function.
                func incForm(a: Int) -> Int {
                    var a = a
                    return a.set(to: .add(1, a))
                }
                """,
            type: .int,
            category: .routines,
            children: [
                Symbol(
                    id: "a",
                    code: "a: Int",
                    type: .int,
                    children: [],
                    meta: [
                        Symbol.MetaData.mutating(true)
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("incForm", category: .routines), expected)

        let caller = try testFactory.init([
            .form([
                .atom("INC-FORM"),
                .atom("FOO")
            ])
        ]).process()

        XCTAssertNoDifference(caller, Symbol(
            "incForm(a: foo)",
            type: .int,
            children: [
                Symbol(
                    id: "a",
                    code: "a: foo",
                    type: .int,
                    meta: [.mutating(true)]
                )
            ]
        ))
    }

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
            code: """
                @discardableResult
                /// The `double` (DOUBLE) function.
                func double(x: Int) -> Int {
                    var x = x
                    return x.add(x)
                }
                """,
            type: .int,
            category: .routines,
            children: [
                Symbol(
                    id: "x",
                    code: "x: Int",
                    type: .int
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("double", category: .routines), expected)

        let caller = try testFactory.init([
            .form([
                .atom("DOUBLE"),
                .atom("FOO")
            ])
        ]).process()

        XCTAssertNoDifference(caller, Symbol(
            "double(x: foo)",
            type: .int,
            children: [
                Symbol(
                    id: "x",
                    code: "x: foo",
                    type: .int
                )
            ]
        ))
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.440mph5j49mp
    func testPowerTo() throws {
        let symbol = try factory.init([
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

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            id: "powerTo",
            code: """
                @discardableResult
                /// The `powerTo` (POWER-TO) function.
                func powerTo(x: Int, y: Int = 2) -> Int {
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
            type: .int,
            category: .routines,
            children: []
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
//        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
//            id: "firstThree",
//            code: """
//                @discardableResult
//                /// The `firstThree` (FIRST-THREE) function.
//                func firstThree(struc: Void) -> [Void] {
//                    var i: Int = 3
//                    return [
//                        { (e: <Unknown>) in
//                            if i.set(to: i.subtract(1)).isZero {
//                                e.mapStop
//                            }
//                            e
//                        }(struc),
//                    ]
//                }
//                """,
//            type: .array(.void),
//            category: .routines
//        ))
//    }

    func testMultifrob() throws {
        let multiFrob = try factory.init([
            .atom("MULTIFROB"),
            .list([
                .atom("X"),
                .atom("ATMS"),
                .string("AUX"),
                .list([
                    .atom("OO"),
                    .list([
                        .atom("OR")
                    ])
                ]),
                .list([
                    .atom("O"),
                    .local("OO")
                ]),
                .list([
                    .atom("L"),
                    .list([
                    ])
                ]),
                .atom("ATM")
            ]),
            .form([
                .atom("REPEAT"),
                .list([
                ]),
                .form([
                    .atom("COND"),
                    .list([
                        .form([
                            .atom("EMPTY?"),
                            .local("ATMS")
                        ]),
                        .form([
                            .atom("RETURN!-"),
                            .form([
                                .atom("COND"),
                                .list([
                                    .form([
                                        .atom("LENGTH?"),
                                        .local("OO"),
                                        .decimal(1)
                                    ]),
                                    .form([
                                        .atom("ERROR"),
                                        .local("X")
                                    ])
                                ]),
                                .list([
                                    .form([
                                        .atom("LENGTH?"),
                                        .local("OO"),
                                        .decimal(2)
                                    ]),
                                    .form([
                                        .atom("NTH"),
                                        .local("OO"),
                                        .decimal(2)
                                    ])
                                ]),
                                .list([
                                    .atom("ELSE"),
                                    .form([
                                        .atom("CHTYPE"),
                                        .local("OO"),
                                        .atom("FORM")
                                    ])
                                ])
                            ])
                        ])
                    ])
                ]),
                .form([
                    .atom("REPEAT"),
                    .list([
                    ]),
                    .form([
                        .atom("COND"),
                        .list([
                            .form([
                                .atom("EMPTY?"),
                                .local("ATMS")
                            ]),
                            .form([
                                .atom("RETURN!-")
                            ])
                        ])
                    ]),
                    .form([
                        .atom("SET"),
                        .atom("ATM"),
                        .form([
                            .atom("NTH"),
                            .local("ATMS"),
                            .decimal(1)
                        ])
                    ]),
                    .form([
                        .atom("SET"),
                        .atom("L"),
                        .list([
                            .form([
                                .atom("COND"),
                                .list([
                                    .form([
                                        .atom("TYPE?"),
                                        .local("ATM"),
                                        .atom("ATOM")
                                    ]),
                                    .form([
                                        .atom("FORM"),
                                        .atom("GVAL"),
                                        .form([
                                            .atom("COND"),
                                            .list([
                                                .form([
                                                    .atom("==?"),
                                                    .local("X"),
                                                    .atom("PRSA")
                                                ]),
                                                .form([
                                                    .atom("PARSE"),
                                                    .form([
                                                        .atom("STRING"),
                                                        .string("V?"),
                                                        .form([
                                                            .atom("SPNAME"),
                                                            .local("ATM")
                                                        ])
                                                    ])
                                                ])
                                            ]),
                                            .list([
                                                .atom("ELSE"),
                                                .local("ATM")
                                            ])
                                        ])
                                    ])
                                ]),
                                .list([
                                    .atom("ELSE"),
                                    .local("ATM")
                                ])
                            ]),
                            .segment(.local("L"))
                        ])
                    ]),
                    .form([
                        .atom("SET"),
                        .atom("ATMS"),
                        .form([
                            .atom("REST"),
                            .local("ATMS")
                        ])
                    ]),
                    .form([
                        .atom("COND"),
                        .list([
                            .form([
                                .atom("==?"),
                                .form([
                                    .atom("LENGTH"),
                                    .local("L")
                                ]),
                                .decimal(3)
                            ]),
                            .form([
                                .atom("RETURN!-")
                            ])
                        ])
                    ])
                ]),
                .form([
                    .atom("SET"),
                    .atom("O"),
                    .form([
                        .atom("REST"),
                        .form([
                            .atom("PUTREST"),
                            .local("O"),
                            .list([
                                .form([
                                    .atom("FORM"),
                                    .atom("EQUAL?"),
                                    .form([
                                        .atom("FORM"),
                                        .atom("GVAL"),
                                        .local("X")
                                    ]),
                                    .segment(.local("L"))
                                ])
                            ])
                        ])
                    ])
                ]),
                .form([
                    .atom("SET"),
                    .atom("L"),
                    .list([
                    ])
                ])
            ])
        ]).process()

        XCTAssertNoDifference(multiFrob.ignoringChildren, Symbol(
            id: "multifrob",
            code: """
                /// The `multifrob` (MULTIFROB) function.
                func multifrob(
                    x: <Unknown>,
                    atms: <Unknown>
                ) {
                    var atm: Int = 0
                    var atms = atms
                    var oo: ZilElement = [or]
                    var o: [Bool] = oo
                    var l: [ZilElement] = []
                    while true {
                        if atms.isEmpty {
                            return if oo.count == 1 {
                                throw FizmoError.mdlError(x)
                            } else if oo.count == 2 {
                                oo.nthElement(2)
                            } else {
                                oo.changeType(form)
                            }
                        }
                        while true {
                            if atms.isEmpty {
                                break
                            }
                            atm.set(to: atms.nthElement(1))
                            l.set(to: [
                                if atm.isType(atom) {
                                    if x.equals(prsa) {
                                        ["V?", atm.printedName].joined().printedName
                                    } else {
                                        atm
                                    }
                                } else {
                                    atm
                                },
                                l,
                            ])
                            atms.set(to: atms.rest())
                            if l.count.equals(3) {
                                break
                            }
                        }
                        o.set(to: o.putRest([x.equals(l)]).rest())
                        l.set(to: [])
                    }
                }
                """,
            type: .void,
            category: .routines
        ))

        let symbol = try Factories.DefineMacro.init([
            .atom("VERB?"),
            .list([
                .string("ARGS"),
                .atom("ATMS")
            ]),
            .form([
                .atom("MULTIFROB"),
                .atom("PRSA"),
                .local("ATMS")
            ])
        ]).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            id: "isVerb",
            code: """
                /// The `isVerb` (VERB?) macro.
                func isVerb(atms: <Unknown>) {
                    multifrob(x: prsa, atms: atms)
                }
                """,
            type: .void,
            category: .routines
        ))
    }
}
