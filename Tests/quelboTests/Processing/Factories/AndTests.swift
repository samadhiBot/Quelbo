//
//  AndTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class AndTests: QuelboTests {
    let factory = Factories.And.self

    override func setUp() {
        super.setUp()

        process("""
            <CONSTANT M-ENTER 3>
            <GLOBAL FOUND-TREASURE-CHEST <>>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("AND"))
    }

    func testAndOneValue() throws {
        let symbol = process("<AND T>")

        XCTAssertNoDifference(symbol, .statement(
            code: ".and(true)",
            type: .booleanTrue
        ))
    }

    func testAndTwoLiterals() throws {
        let symbol = process("<AND T T>")

        XCTAssertNoDifference(symbol, .statement(
            code: ".and(true, true)",
            type: .booleanTrue
        ))
    }

    func testAndThreeLiterals() throws {
        let symbol = process("<AND T <> T>")

        XCTAssertNoDifference(symbol, .statement(
            code: ".and(true, false, true)",
            type: .booleanTrue
        ))
    }

    func testAndDecimals() throws {
        let symbol = process("<AND 1 0 2>")

        XCTAssertNoDifference(symbol, .statement(
            code: ".and(1, 0, 2)",
            type: .int
        ))
    }

    func testAndTwoBooleanExpressions() throws {
        localVariables.append(
            Statement(id: "rarg", type: .int)
        )

        let symbol = try factory.init([
            .form([
                .atom("=?"),
                .local("RARG"),
                .global(.atom("M-ENTER")),
            ]),
            .form([
                .atom("NOT"),
                .global(.atom("FOUND-TREASURE-CHEST")),
            ]),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
            .and(
                rarg.equals(Constants.mEnter),
                .isNot(Globals.foundTreasureChest)
            )
            """,
            type: .bool
        ))
    }
}
