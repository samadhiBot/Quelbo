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
        AssertSameFactory(factory, Game.findFactory("DEFINE"))
    }

    // https://mdl-language.readthedocs.io/en/latest/07-structured-objects/#755-form-and-iform
    func testSimpleDefine() throws {
        let definition: [Token] = [
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
        ]

        let symbol = try factory.init(definition, with: &localVariables).process()

        let expected = Definition(
            id: "incForm",
            tokens: definition.droppingFirst
        )

        XCTAssertNoDifference(symbol, .definition(expected))
        XCTAssertNoDifference(Game.findDefinition("incForm"), expected)

        XCTAssertNil(Game.routines.find("incForm(foo:)"))

        let fooCaller = try testFactory.init([
            .form([
                .atom("INC-FORM"),
                .atom("FOO")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(
            Game.routines.find("incForm(foo:)"),
            Statement(
                id: "incForm(foo:)",
                code: """
                    @discardableResult
                    /// The `incForm(foo:)` (INC-FORM) function.
                    func incForm(foo: Int) -> Int {
                        var foo: Int = foo
                        return foo.set(to: .add(1, foo))
                    }
                    """,
                type: .int,
                parameters: [
                    Instance(Variable(
                        id: "foo",
                        type: .int,
                        category: .globals,
                        isMutable: true
                    ))
                ],
                category: .routines
            )
        )

        XCTAssertNoDifference(fooCaller, .statement(
            code: "incForm(foo: foo)",
            type: .int
        ))

        XCTAssertNil(Game.routines.find("incForm(bar:)"))

        let barCaller = try testFactory.init([
            .form([
                .atom("INC-FORM"),
                .atom("BAR")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(
            Game.routines.find("incForm(bar:)"),
            Statement(
                id: "incForm(bar:)",
                code: """
                    @discardableResult
                    /// The `incForm(bar:)` (INC-FORM) function.
                    func incForm(bar: Int) -> Int {
                        var bar: Int = bar
                        return bar.set(to: .add(1, bar))
                    }
                    """,
                type: .int,
                parameters: [
                    Instance(Variable(
                        id: "bar",
                        type: .int,
                        category: .globals,
                        isMutable: true
                    ))
                ],
                category: .routines
            )
        )

        XCTAssertNoDifference(barCaller, .statement(
            code: "incForm(bar: bar)",
            type: .int
        ))
    }

    // https://mdl-language.readthedocs.io/en/latest/17-macro-operations/#1722-example
    func testDefineWithDecl() throws {
        let definition: [Token] = [
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
        ]

        let symbol = try factory.init(definition, with: &localVariables).process()

        let expected = Definition(
            id: "double",
            tokens: definition.droppingFirst
        )

        XCTAssertNoDifference(symbol, .definition(expected))
        XCTAssertNoDifference(Game.findDefinition("double"), expected)

        XCTAssertNil(Game.routines.find("double(foo:)"))

        let fooCaller = try testFactory.init([
            .form([
                .atom("DOUBLE"),
                .atom("FOO")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(
            Game.routines.find("double(foo:)"),
            Statement(
                id: "double(foo:)",
                code: """
                    @discardableResult
                    /// The `double(foo:)` (DOUBLE) function.
                    func double(foo: Int) -> Int {
                        var foo: Int = foo
                        // Declare(foo: Int)
                        return foo.add(foo)
                    }
                    """,
                type: .int,
                parameters: [
                    Instance(Variable(
                        id: "foo",
                        type: .int,
                        isMutable: true
                    ))
                ],
                category: .routines
            )
        )

        XCTAssertNoDifference(fooCaller, .statement(
            code: "double(foo: foo)",
            type: .int
        ))

        XCTAssertNil(Game.routines.find("double(bar:)"))

        let barCaller = try testFactory.init([
            .form([
                .atom("DOUBLE"),
                .atom("BAR")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(
            Game.routines.find("double(bar:)"),
            Statement(
                id: "double(bar:)",
                code: """
                    @discardableResult
                    /// The `double(bar:)` (DOUBLE) function.
                    func double(bar: Int) -> Int {
                        var bar: Int = bar
                        // Declare(bar: Int)
                        return bar.add(bar)
                    }
                    """,
                type: .int,
                parameters: [
                    Instance(Variable(
                        id: "bar",
                        type: .int,
                        isMutable: true
                    ))
                ],
                category: .routines
            )
        )

        XCTAssertNoDifference(barCaller, .statement(
            code: "double(bar: bar)",
            type: .int
        ))
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.440mph5j49mp
    func testPowerTo() throws {
        let definition = try parse("""
            <DEFINE POWER-TO ACT (X "OPT" (Y 2))
                <COND (<=? .Y 0> <RETURN 1 .ACT>)>
                <REPEAT ((Z 1)(I 0))
                    <SET Z <* .Z .X>>
                    <SET I <+ .I 1>>
                    <COND (<=? .I .Y> <RETURN .Z>)>
                >
            >
        """).droppingFirst

        let symbol = try factory.init(definition, with: &localVariables).process()

        let expected = Definition(
            id: "powerTo",
            tokens: definition.droppingFirst
        )

        XCTAssertNoDifference(symbol, .definition(expected))
        XCTAssertNoDifference(Game.findDefinition("powerTo"), expected)

        XCTAssertNil(Game.routines.find("powerTo(foo:)"))

        let fooCaller = try testFactory.init([
            .form([
                .atom("POWER-TO"),
                .atom("FOO")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(
            Game.routines.find("powerTo(foo:)"),
            Statement(
                id: "powerTo(foo:)",
                code: """
                    @discardableResult
                    /// The `powerTo(foo:)` (POWER-TO) function.
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
                parameters: [
                    Instance(
                        Variable(
                            id: "foo",
                            type: .int,
                            isMutable: true
                        )
                    ),
                    Instance(
                        Variable(
                            id: "y",
                            type: .int
                        ),
                        isOptional: true
                    )
                ],
                category: .routines
            )
        )

        XCTAssertNoDifference(fooCaller, .statement(
            code: "powerTo(foo: foo)",
            type: .int
        ))
    }

    func testMakeReadbufDefine() throws {
        try Factories.Constant([
            .atom("READBUF-SIZE"),
            .decimal(100)
        ], with: &localVariables).process()

        let definition: [Token] = [
            .atom("MAKE-READBUF"),
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

        let symbol = try factory.init(definition, with: &localVariables).process()

        let expected = Definition(
            id: "makeReadbuf",
            tokens: definition.droppingFirst
        )

        XCTAssertNoDifference(symbol, .definition(expected))
        XCTAssertNoDifference(Game.findDefinition("makeReadbuf"), expected)

        XCTAssertNil(Game.routines.find("makeReadbuf()"))

        let kbdReadbuf = try Factories.Constant([
            .atom("KBD-READBUF"),
            .form([
                .atom("MAKE-READBUF")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(
            Game.routines.find("makeReadbuf()"),
            Statement(
                id: "makeReadbuf()",
                code: """
                    @discardableResult
                    /// The `makeReadbuf()` (MAKE-READBUF) function.
                    func makeReadbuf() -> Table {
                        return Table(
                            count: readbufSize,
                            flags: [.byte, .none]
                        )
                    }
                    """,
                type: .table,
                category: .routines
            )
        )

        XCTAssertNoDifference(kbdReadbuf, .statement(
            id: "kbdReadbuf",
            code: "let kbdReadbuf: Table = makeReadbuf()",
            type: .table,
            category: .constants
        ))

        let editReadbuf = try Factories.Constant([
            .atom("EDIT-READBUF"),
            .form([
                .atom("MAKE-READBUF")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(editReadbuf, .statement(
            id: "editReadbuf",
            code: "let editReadbuf: Table = makeReadbuf()",
            type: .table,
            category: .constants
        ))
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.243i4a2
    func testFirstThree() throws {
        let definition = try parse("""
            <DEFINE FIRST-THREE (STRUC "AUX" (I 3))
                <MAPF ,LIST
                <FUNCTION (E)
                    <COND (<0? <SET I <- .I 1>>> <MAPSTOP .E>)>
                .E> .STRUC>>
        """).droppingFirst

        let symbol = try factory.init(definition, with: &localVariables).process()

        let expected = Definition(
            id: "firstThree",
            tokens: definition.droppingFirst
        )

        XCTAssertNoDifference(symbol, .definition(expected))
        XCTAssertNoDifference(Game.findDefinition("firstThree"), expected)

        XCTAssertNil(Game.routines.find("firstThree(string:)"))

        let abcCaller = try testFactory.init([
            .form([
                .atom("FIRST-THREE"),
                .string("ABCDEFG")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(
            Game.routines.find("firstThree(string:)"),
            Statement(
                id: "firstThree(string:)",
                code: """
                    @discardableResult
                    /// The `firstThree(string:)` (FIRST-THREE) function.
                    func firstThree(
                        string: String = "ABCDEFG"
                    ) -> [(<Unknown>) -> <Unknown>] {
                        var i: Int = 3
                        return [
                            { (e: <Unknown>) -> <Unknown> in
                                if i.set(to: i.subtract(1)).isZero {
                                    return e
                                }
                                return e
                            }("ABCDEFG"),
                        ]
                    }
                    """,
                type: .array(.string),
                category: .routines
            )
        )

        XCTAssertNoDifference(abcCaller, .statement(
            code: """
                firstThree(string: "ABCDEFG")
                """,
            type: .function([.string], .string)
        ))
    }

    func testMultifrob() throws {
        localVariables.append(
            Variable(id: "prsa", type: .object)
        )

        let definition: [Token] = try parse("""
            <DEFINE MULTIFROB (X ATMS "AUX" (OO (OR)) (O .OO) (L ()) ATM)
                <REPEAT ()
                    <COND (<EMPTY? .ATMS>
                           <RETURN!- <COND (<LENGTH? .OO 1> <ERROR .X>)
                                   (<LENGTH? .OO 2> <NTH .OO 2>)
                                   (ELSE <CHTYPE .OO FORM>)>>)>
                    <REPEAT ()
                        <COND (<EMPTY? .ATMS> <RETURN!->)>
                        <SET ATM <NTH .ATMS 1>>
                        <SET L
                             (<COND (<TYPE? .ATM ATOM>
                                 <FORM GVAL
                                   <COND (<==? .X PRSA>
                                      <PARSE
                                        <STRING "V?"
                                            <SPNAME .ATM>>>)
                                     (ELSE .ATM)>>)
                                (ELSE .ATM)>
                              !.L)>
                        <SET ATMS <REST .ATMS>>
                        <COND (<==? <LENGTH .L> 3> <RETURN!->)>>
                    <SET O <REST <PUTREST .O (<FORM EQUAL? <FORM GVAL .X> !.L>)>>>
                    <SET L ()>>>
        """).droppingFirst

        let symbol = try factory.init(definition, with: &localVariables).process()

        let expected = Definition(
            id: "multifrob",
            tokens: definition.droppingFirst
        )

        XCTAssertNoDifference(symbol, .definition(expected))
        XCTAssertNoDifference(Game.findDefinition("multifrob"), expected)

        XCTAssertNil(Game.routines.find("multifrob(prsa:atms)"))

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
        ], with: &localVariables).process()

        XCTAssertNoDifference(isVerb, .statement(
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
            Game.routines.find("multifrob(prsa:atms)"),
            Statement(
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
                category: .routines
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
//        ], with: &localVariables).process()
//
//        let expected = Symbol(
//            id: "multiBits",
//            code: """
//                """,
//            type: .int,
//            category: .functions
//        )
//
//        XCTAssertNoDifference(symbol, expected)
////        XCTAssertNoDifference(
////            try Game.find("multiBits", category: .functions),
////            expected
////        )
//
////        let caller = try testFactory.init([
////            .form([
////                .atom("DOUBLE"),
////                .atom("FOO")
////            ])
////        ], with: &localVariables).process()
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
