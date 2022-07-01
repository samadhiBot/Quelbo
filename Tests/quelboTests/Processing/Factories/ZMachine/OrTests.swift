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

        Game.commit([
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
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".or(true)",
            type: .bool
        ))
    }

    func testOrTwoBooleans() throws {
        let symbol = try factory.init([
            .bool(true),
            .bool(true)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".or(true, true)",
            type: .bool
        ))
    }

    func testOrThreeBooleans() throws {
        let symbol = try factory.init([
            .bool(true),
            .bool(false),
            .bool(true)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".or(true, false, true)",
            type: .bool
        ))
    }

    func testOrDecimals() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(0),
            .decimal(2),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".or(1, 0, 2)",
            type: .int
        ))
    }

    func testOrTwoBooleanExpressions() throws {
        registry.insert(
            Symbol(id: "rarg", type: .int)
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
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
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
