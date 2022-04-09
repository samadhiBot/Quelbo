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
            Symbol("foundTreasureChest", type: .bool, category: .globals),
            Symbol("mEnter", type: .int, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("AND"))
    }

    func testAndOneValue() throws {
        XCTAssertThrowsError(
            try factory.init([
                .bool(true)
            ]).process()
        )
    }

    func testAndTwoLiterals() throws {
        let symbol = try factory.init([
            .bool(true),
            .bool(true)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "and(true, true)",
            type: .bool,
            children: [
                Symbol("true", type: .bool),
                Symbol("true", type: .bool),
            ]
        ))
    }

    func testAndThreeLiterals() throws {
        let symbol = try factory.init([
            .bool(true),
            .bool(false),
            .bool(true)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "and(true, false, true)",
            type: .bool,
            children: [
                Symbol("true", type: .bool),
                Symbol("false", type: .bool),
                Symbol("true", type: .bool),
            ]
        ))
    }

    func testAndDecimals() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(0),
            .decimal(2),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "and(1, 0, 2)",
            type: .int,
            children: [
                Symbol("1", type: .int),
                Symbol("0", type: .int),
                Symbol("2", type: .int),
            ]
        ))
    }

    func testAndTwoBooleanExpressions() throws {
        let symbol = try factory.init([
            .form([
                .atom("=?"),
                .atom(".RARG"),
                .atom(",M-ENTER"),
            ]),
            .form([
                .atom("NOT"),
                .atom(",FOUND-TREASURE-CHEST"),
            ]),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "and(rarg.equals(mEnter), !foundTreasureChest)",
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
                    id: "!foundTreasureChest",
                    type: .bool,
                    children: [
                        Symbol("foundTreasureChest", type: .bool, category: .globals)
                    ]
                )
            ]
        ))
    }
}
