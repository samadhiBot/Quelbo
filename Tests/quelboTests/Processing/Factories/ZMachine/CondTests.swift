//
//  CondTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class CondTests: QuelboTests {
    let factory = Factories.Cond.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
            Symbol("mEnter", type: .int, category: .globals),
            Symbol("isIn", type: .bool, category: .routines),
            Symbol("thisIsIt", type: .bool, category: .routines),
            Symbol("troll", type: .object, category: .objects)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("COND"))
    }

    func testSingleCondition() throws {
        let symbol = try factory.init([
            .list([
                .form([
                    .atom("EQUAL?"),
                    .atom(".RARG"),
                    .atom(",M-ENTER")
                ]),
                .form([
                    .atom("PRINT"),
                    .string("Rarg equals mEnter")
                ])
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
            if rarg.equals(mEnter) {
                output("Rarg equals mEnter")
            }
            """,
            type: .list,
            children: [
                Symbol(
                    "<List>",
                    type: .list,
                    children: [
                        Symbol(
                            "rarg.equals(mEnter)",
                            type: .bool,
                            children: [
                                Symbol("rarg", type: .int),
                                Symbol("mEnter", type: .int, category: .globals)
                            ]
                        ),
                        Symbol(
                            id: "output(\"Rarg equals mEnter\")",
                            code: "output(\"Rarg equals mEnter\")",
                            type: .bool,
                            children: [
                                Symbol("\"Rarg equals mEnter\"", type: .string)
                            ]
                        )
                    ]
                )
            ]
        ))
    }

    func testDoubleCondition() throws {
        let symbol = try factory.init([
            .list([
                .form([
                    .atom("EQUAL?"),
                    .atom(".RARG"),
                    .atom(",M-ENTER")
                ]),
                .form([
                    .atom("PRINT"),
                    .string("Rarg equals mEnter")
                ])
            ]),
            .list([
                .form([
                    .atom("IN?"),
                    .atom(",TROLL"),
                    .atom(",HERE")
                ]),
                .form([
                    .atom("THIS-IS-IT"),
                    .atom(",TROLL")
                ])
            ]),
        ]).process()

        XCTAssertNoDifference(symbol.code, """
        if rarg.equals(mEnter) {
            output("Rarg equals mEnter")
        } else if isIn(troll, here) {
            thisIsIt()
        }
        """)
    }
}
