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

        try! Game.commit([
            .variable(id: "foundTreasureChest", type: .bool, category: .globals),
            .variable(id: "mEnter", type: .int, category: .globals),
        ])
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
        let symbol = try factory.init([
            .bool(true),
            .bool(false),
            .bool(true)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".and(true, false, true)",
            type: .booleanTrue
        ))
    }

    func testAndDecimals() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(0),
            .decimal(2),
        ], with: &localVariables).process()

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
                rarg.equals(mEnter),
                .isNot(foundTreasureChest)
            )
            """,
            type: .bool
        ))
    }
}
