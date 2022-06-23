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
            Symbol("foundTreasureChest", type: .bool, category: .globals),
            Symbol("mEnter", type: .int, category: .globals),
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
            type: .bool,
            children: [
                .trueSymbol,
            ]
        ))
    }

    func testOrTwoBooleans() throws {
        let symbol = try factory.init([
            .bool(true),
            .bool(true)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".or(true, true)",
            type: .bool,
            children: [
                .trueSymbol,
                .trueSymbol,
            ]
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
            type: .bool,
            children: [
                .trueSymbol,
                .falseSymbol,
                .trueSymbol,
            ]
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
            type: .int,
            children: [
                Symbol("1", type: .int, meta: [.isLiteral]),
                .zeroSymbol,
                Symbol("2", type: .int, meta: [.isLiteral]),
            ]
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
            type: .bool,
            children: [
                Symbol(
                    "rarg.equals(mEnter)",
                    type: .bool,
                    children: [
                        Symbol("rarg", type: .int),
                        Symbol("mEnter", type: .int, category: .globals),
                    ]
                ),
                Symbol(
                    ".isNot(foundTreasureChest)",
                    type: .bool,
                    children: [
                        Symbol("foundTreasureChest", type: .bool, category: .globals)
                    ]
                )
            ]
        ))
    }
}
