//
//  OrTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class OrTests: QuelboTests {
    let factory = Factories.Or.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "foundTreasureChest", type: .bool, category: .globals),
            .variable(id: "mEnter", type: .int, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("OR", type: .zCode))
    }

    func testOrOneValue() throws {
        let symbol = try factory.init([
            .bool(true),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".or(true)",
            type: .booleanTrue
        ))
    }

    func testOrTwoBooleans() throws {
        let symbol = try factory.init([
            .bool(true),
            .bool(true)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".or(true, true)",
            type: .booleanTrue
        ))
    }

    func testOrThreeBooleans() throws {
        let symbol = try factory.init([
            .bool(true),
            .bool(false),
            .bool(true)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".or(true, false, true)",
            type: .booleanTrue
        ))
    }

    func testOrDecimals() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(0),
            .decimal(2),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".or(1, 0, 2)",
            type: .int
        ))
    }

    func testOrTwoBooleanExpressions() throws {
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
            .or(
                rarg.equals(mEnter),
                .isNot(foundTreasureChest)
            )
            """,
            type: .bool
        ))
    }
}
