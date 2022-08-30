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
        let symbol = try factory.init([
            .bool(true),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".and(true)",
            type: .bool,
            confidence: .certain
        ))
    }

    func testAndTwoLiterals() throws {
        let symbol = try factory.init([
            .bool(true),
            .bool(true),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".and(true, true)",
            type: .bool,
            confidence: .certain
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
            type: .bool,
            confidence: .certain
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
            type: .int,
            confidence: .certain
        ))
    }

    func testAndTwoBooleanExpressions() throws {
        localVariables.append(
            Variable(id: "rarg", type: .int)
        )

        let symbol = try factory.init([
            .form([
                .atom("=?"),
                .local("RARG"),
                .global("M-ENTER"),
            ]),
            .form([
                .atom("NOT"),
                .global("FOUND-TREASURE-CHEST"),
            ]),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
            .and(
                rarg.equals(mEnter),
                .isNot(foundTreasureChest)
            )
            """,
            type: .bool,
            confidence: .certain
        ))
    }
}
