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
        AssertSameFactory(factory, Game.findFactory("DEFMAC"))
    }

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "contBit", type: .bool, category: .flags),
            .variable(id: "doorBit", type: .bool, category: .flags),
        ])
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
        ], with: &localVariables).process()

        let expected = Statement(
            id: "inc",
            code: """
                @discardableResult
                /// The `inc` (INC) macro.
                func inc(atm: Int, n: Int = 1) -> Int {
                    var atm: Int = atm
                    return atm.set(to: atm.add(n))
                }
                """,
            type: .int,
            parameters: [
                Instance(
                    Variable(
                        id: "atm",
                        type: .int,
                        category: Category.globals,
                        isMutable: true
                    )
                ),
                Instance(
                    Variable(
                        id: "n",
                        type: .int,
                        category: nil,
                        isMutable: nil
                    ),
                    isOptional: true
                )
            ],
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("inc"), expected)
    }

    func testIsOpenableMacro() throws {
        let symbol = try factory.init([
            .atom("OPENABLE?"),
            .list([
                .quote(.atom("OBJ"))
            ]),
            .form([
                .atom("FORM"),
                .atom("OR"),
                .form([
                    .atom("FORM"),
                    .atom("FSET?"),
                    .local("OBJ"),
                    .quote(.global("DOORBIT"))
                ]),
                .form([
                    .atom("FORM"),
                    .atom("FSET?"),
                    .local("OBJ"),
                    .quote(.global("CONTBIT"))
                ])
            ])
        ], with: &localVariables).process()

        let expected = Statement(
            id: "isOpenable",
            code: """
                @discardableResult
                /// The `isOpenable` (OPENABLE?) macro.
                func isOpenable(obj: Object) -> Bool {
                    return .or(
                        obj.hasFlag(doorBit),
                        obj.hasFlag(contBit)
                    )
                }
                """,
            type: .bool,
            parameters: [
                Instance(
                    Variable(
                        id: "obj",
                        type: .object
                    )
                )
            ],
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("isOpenable"), expected)
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
        ], with: &localVariables).process()

        let expected = Statement(
            id: "double",
            code: """
                @discardableResult
                /// The `double` (DOUBLE) macro.
                func double(any: Int) -> Int {
                    do {
                        var x: Int = any
                        // Declare(x: Int)
                        return x.add(x)
                    }
                }
                """,
            type: .int,
            parameters: [
                Instance(
                    Variable(
                        id: "any",
                        type: .int
                    )
                )
            ],
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("double"), expected)
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
//        ], with: &localVariables).process()
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
//        XCTAssertNoDifference(try Game.find("bottles", category: .routines), expected)
//    }

}
