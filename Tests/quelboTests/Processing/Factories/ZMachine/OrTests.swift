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
            Symbol(id: "foundTreasureChest", type: .bool, category: .globals),
            Symbol(id: "mEnter", type: .int, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("OR"))
    }

    func testOrOneValue() throws {
        let symbol = try factory.init([
            .bool(true),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".or(true)",
            type: .bool
        ))
    }

    func testOrTwoBooleans() throws {
        let symbol = try factory.init([
            .bool(true),
            .bool(true)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".or(true, true)",
            type: .bool
        ))
    }

    func testOrThreeBooleans() throws {
        let symbol = try factory.init([
            .bool(true),
            .bool(false),
            .bool(true)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".or(true, false, true)",
            type: .bool
        ))
    }

    func testOrDecimals() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(0),
            .decimal(2),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".or(1, 0, 2)",
            type: .int
        ))
    }

    func testOrTwoBooleanExpressions() throws {
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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
            .or(
                rarg.equals(mEnter),
                .isNot(foundTreasureChest)
            )
            """,
            type: .bool
        ))
    }
}
