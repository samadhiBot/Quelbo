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
        let definition: [Token] = [
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
        ]
        let symbol = try factory.init([.atom("INC-FORM")] + definition).process()

        let expected = Symbol(
            id: "incForm",
            category: .definitions,
            meta: [.zil(definition)]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("incForm", category: .definitions), expected)

        XCTAssertThrowsError(try Game.find("incForm(foo)", category: .functions))

        let fooCaller = try testFactory.init([
            .form([
                .atom("INC-FORM"),
                .atom("FOO")
            ])
        ]).process()

        XCTAssertNoDifference(
            try Game.find("incForm(foo)", category: .functions),
            Symbol(
                id: "incForm(foo)",
                code: """
                @discardableResult
                /// The `incForm` (INC-FORM) function.
                func incForm(foo: Int) -> Int {
                    var foo = foo
                    return foo.set(to: .add(1, foo))
                }
                """,
                type: .int,
                category: .functions,
                children: [
                    Symbol(
                        id: "foo",
                        code: "foo: Int",
                        type: .int,
                        meta: [.mutating(true)]
                    )
                ]
            )
        )

        XCTAssertNoDifference(
            fooCaller.ignoringChildren,
            Symbol("incForm(foo: foo)", type: .int)
        )

        XCTAssertThrowsError(try Game.find("incForm(bar)", category: .functions))

        let barCaller = try testFactory.init([
            .form([
                .atom("INC-FORM"),
                .atom("BAR")
            ])
        ]).process()

        XCTAssertNoDifference(
            try Game.find("incForm(bar)", category: .functions),
            Symbol(
                id: "incForm(bar)",
                code: """
                @discardableResult
                /// The `incForm` (INC-FORM) function.
                func incForm(bar: Int) -> Int {
                    var bar = bar
                    return bar.set(to: .add(1, bar))
                }
                """,
                type: .int,
                category: .functions,
                children: [
                    Symbol(
                        id: "bar",
                        code: "bar: Int",
                        type: .int,
                        meta: [.mutating(true)]
                    )
                ]
            )
        )

        XCTAssertNoDifference(
            barCaller.ignoringChildren,
            Symbol("incForm(bar: bar)", type: .int)
        )
    }

    // https://mdl-language.readthedocs.io/en/latest/17-macro-operations/#1722-example
    func testDefineWithDecl() throws {
        let definition: [Token] = [
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
        ]
        let symbol = try factory.init([.atom("DOUBLE")] + definition).process()

        let expected = Symbol(
            id: "double",
            category: .definitions,
            meta: [.zil(definition)]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("double", category: .definitions), expected)

        XCTAssertThrowsError(try Game.find("double(foo)", category: .functions))

        let fooCaller = try testFactory.init([
            .form([
                .atom("DOUBLE"),
                .atom("FOO")
            ])
        ]).process()

        XCTAssertNoDifference(
            fooCaller.ignoringChildren,
            Symbol("double(foo: foo)", type: .int)
        )

        XCTAssertNoDifference(
            try Game.find("double(foo)", category: .functions).ignoringChildren,
            Symbol(
                id: "double(foo)",
                code: """
                    @discardableResult
                    /// The `double` (DOUBLE) function.
                    func double(foo: Int) -> Int {
                        var foo = foo
                        return foo.add(foo)
                    }
                    """,
                type: .int,
                category: .functions
            )
        )

        XCTAssertThrowsError(try Game.find("double(bar)", category: .functions))

        let barCaller = try testFactory.init([
            .form([
                .atom("DOUBLE"),
                .atom("BAR")
            ])
        ]).process()

        XCTAssertNoDifference(
            barCaller.ignoringChildren,
            Symbol("double(bar: bar)", type: .int)
        )

        XCTAssertNoDifference(
            try Game.find("double(bar)", category: .functions).ignoringChildren,
            Symbol(
                id: "double(bar)",
                code: """
                    @discardableResult
                    /// The `double` (DOUBLE) function.
                    func double(bar: Int) -> Int {
                        var bar = bar
                        return bar.add(bar)
                    }
                    """,
                type: .int,
                category: .functions
            )
        )
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.440mph5j49mp
    func testPowerTo() throws {
        let definition: [Token] = [
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
        ]
        let symbol = try factory.init([.atom("POWER-TO")] + definition).process()

        let expected = Symbol(
            id: "powerTo",
            category: .definitions,
            meta: [.zil(definition)]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("powerTo", category: .definitions), expected)

        XCTAssertThrowsError(try Game.find("double(powerTo)", category: .functions))

        let fooCaller = try testFactory.init([
            .form([
                .atom("POWER-TO"),
                .atom("FOO")
            ])
        ]).process()

        XCTAssertNoDifference(
            fooCaller.ignoringChildren,
            Symbol("powerTo(foo: foo)", type: .int)
        )

        XCTAssertNoDifference(
            try Game.find("powerTo(foo)", category: .functions).ignoringChildren,
            Symbol(
                id: "powerTo(foo)",
                code: """
                    @discardableResult
                    /// The `powerTo` (POWER-TO) function.
                    func powerTo(foo: Int, y: Int = 2) -> Int {
                        if y.equals(0) {
                            return 1
                        }
                        var z: Int = 1
                        var i: Int = 0
                        while true {
                            z.set(to: z.multiply(foo))
                            i.set(to: i.add(1))
                            if i.equals(y) {
                                return z
                            }
                        }
                    }
                    """,
                type: .int,
                category: .functions,
                children: []
            )
        )
    }

    func testMakeReadbufDefine() throws {
        let types = SymbolFactory.TypeRegistry()

        let _ = try Factories.Constant([
            .atom("READBUF-SIZE"),
            .decimal(100)
        ], with: types).process()

        let definition: [Token] = [
            .list([
            ]),
            .form([
                .atom("ITABLE"),
                .atom("NONE"),
                .global("READBUF-SIZE"),
                .list([
                    .atom("BYTE")
                ])
            ])
        ]
        let symbol = try factory.init([.atom("MAKE-READBUF")] + definition, with: types).process()

        let expected = Symbol(
            id: "makeReadbuf",
            category: .definitions,
            meta: [.zil(definition)]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("makeReadbuf", category: .definitions), expected)

        XCTAssertThrowsError(
            try Game.find("makeReadbuf()", category: .functions)
        )

        let kbdReadbuf = try Factories.Constant([
            .atom("KBD-READBUF"),
            .form([
                .atom("MAKE-READBUF")
            ])
        ], with: types).process()

        XCTAssertNoDifference(kbdReadbuf.ignoringChildren, Symbol(
            id: "kbdReadbuf",
            code: "let kbdReadbuf: Table = makeReadbuf()",
            type: .table,
            category: .constants
        ))

        XCTAssertNoDifference(
            try Game.find("makeReadbuf()", category: .functions).ignoringChildren,
            Symbol(
                id: "makeReadbuf()",
                code: """
                    @discardableResult
                    /// The `makeReadbuf` (MAKE-READBUF) function.
                    func makeReadbuf() -> Table {
                        return Table(
                            count: readbufSize,
                            flags: [.byte, .none]
                        )
                    }
                    """,
                type: .table,
                category: .functions
            )
        )

        let editReadbuf = try Factories.Constant([
            .atom("EDIT-READBUF"),
            .form([
                .atom("MAKE-READBUF")
            ])
        ], with: types).process()

        XCTAssertNoDifference(editReadbuf.ignoringChildren, Symbol(
            id: "editReadbuf",
            code: "let editReadbuf: Table = makeReadbuf()",
            type: .table,
            category: .constants
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
//            category: .functions
//        ))
//    }

    func testMultifrob() throws {
        let types = SymbolFactory.TypeRegistry(["prsa": .object])

        let definition: [Token] = [
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
        ]

        let symbol = try factory.init([.atom("MULTIFROB")] + definition, with: types).process()

        let expected = Symbol(
            id: "multifrob",
            category: .definitions,
            meta: [.zil(definition)]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("multifrob", category: .definitions), expected)

        XCTAssertThrowsError(
            try Game.find("multifrob(prsa:atms)", category: .functions)
        )

        let isVerb = try Factories.DefineMacro([
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
        ], with: types).process()

        XCTAssertNoDifference(isVerb.ignoringChildren, Symbol(
            id: "isVerb",
            code: """
                /// The `isVerb` (VERB?) macro.
                func isVerb(atms: <Unknown>) {
                    multifrob(
                        prsa: prsa,
                        atms: atms
                    )
                }
                """,
            type: .void,
            category: .routines
        ))

        XCTAssertNoDifference(
            try Game.find("multifrob(prsa:atms)", category: .functions).ignoringChildren,
            Symbol(
                id: "multifrob(prsa:atms)",
                code: """
                    /// The `multifrob` (MULTIFROB) function.
                    func multifrob(
                        prsa: Object,
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
                                    throw FizmoError.mdlError(prsa)
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
                                        if prsa.equals(prsa) {
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
                            o.set(to: o.putRest([prsa.equals(l)]).rest())
                            l.set(to: [])
                        }
                    }
                    """,
                type: .void,
                category: .functions
            )
        )
    }

//    func testDefineMultiBits() throws {
//        let symbol = try factory.init([
//            .atom("MULTIBITS"),
//            .list([
//                .atom("X"),
//                .atom("OBJ"),
//                .atom("ATMS"),
//                .string("AUX"),
//                .list([
//                    .atom("O"),
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
//                                        .local("O"),
//                                        .decimal(1)
//                                    ]),
//                                    .form([
//                                        .atom("NTH"),
//                                        .local("O"),
//                                        .decimal(1)
//                                    ])
//                                ]),
//                                .list([
//                                    .form([
//                                        .atom("==?"),
//                                        .local("X"),
//                                        .atom("FSET?")
//                                    ]),
//                                    .form([
//                                        .atom("FORM"),
//                                        .atom("OR"),
//                                        .segment(.local("O"))
//                                    ])
//                                ]),
//                                .list([
//                                    .atom("ELSE"),
//                                    .form([
//                                        .atom("FORM"),
//                                        .atom("PROG"),
//                                        .list([
//                                        ]),
//                                        .segment(.local("O"))
//                                    ])
//                                ])
//                            ])
//                        ])
//                    ])
//                ]),
//                .form([
//                    .atom("SET"),
//                    .atom("ATM"),
//                    .form([
//                        .atom("NTH"),
//                        .local("ATMS"),
//                        .decimal(1)
//                    ])
//                ]),
//                .form([
//                    .atom("SET"),
//                    .atom("ATMS"),
//                    .form([
//                        .atom("REST"),
//                        .local("ATMS")
//                    ])
//                ]),
//                .form([
//                    .atom("SET"),
//                    .atom("O"),
//                    .list([
//                        .form([
//                            .atom("FORM"),
//                            .local("X"),
//                            .local("OBJ"),
//                            .form([
//                                .atom("COND"),
//                                .list([
//                                    .form([
//                                        .atom("TYPE?"),
//                                        .local("ATM"),
//                                        .atom("FORM")
//                                    ]),
//                                    .local("ATM")
//                                ]),
//                                .list([
//                                    .atom("ELSE"),
//                                    .form([
//                                        .atom("FORM"),
//                                        .atom("GVAL"),
//                                        .local("ATM")
//                                    ])
//                                ])
//                            ])
//                        ]),
//                        .segment(.local("O"))
//                    ])
//                ])
//            ])
//        ]).process()
//
//        let expected = Symbol(
//            id: "multiBits",
//            code: """
//                """,
//            type: .int,
//            category: .functions
//        )
//
//        XCTAssertNoDifference(symbol.ignoringChildren, expected)
////        XCTAssertNoDifference(
////            try Game.find("multiBits", category: .functions).ignoringChildren,
////            expected
////        )
//
////        let caller = try testFactory.init([
////            .form([
////                .atom("DOUBLE"),
////                .atom("FOO")
////            ])
////        ]).process()
////
////        XCTAssertNoDifference(caller, Symbol(
////            "double(x: foo)",
////            type: .int,
////            children: [
////                Symbol(
////                    id: "x",
////                    code: "x: foo",
////                    type: .int
////                )
////            ]
////        ))
//    }
}
