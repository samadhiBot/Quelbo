//
//  RoutineCallTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RoutineCallTests: QuelboTests {
    override func setUp() {
        super.setUp()

        try! Game.commit(
            Symbol(
                id: "bagOfCoinsFunc",
                type: .void,
                category: .routines
            ),
            Symbol(
                id: "oneFunc",
                type: .int,
                category: .routines,
                children: [
                    Symbol(id: "number", type: .int, meta: [.isLiteral])
                ]
            ),
            Symbol(
                id: "twoFunc",
                type: .string,
                category: .routines,
                children: [
                    Symbol(id: "answer", type: .string, meta: [.isLiteral]),
                    Symbol(id: "number", type: .int, meta: [.isLiteral]),
                ]
            ),
            Symbol(
                id: "threeFunc",
                type: .string,
                category: .routines,
                children: [
                    Symbol(id: "answer", type: .string, meta: [.isLiteral]),
                    Symbol(id: "isValid", type: .bool),
                    Symbol(id: "number", type: .int, meta: [.isLiteral]),
                ]
            )
        )
    }

    func testProcessRoutineZeroParams() throws {
        let symbol = try Factories.RoutineCall([
            .atom("BAG-OF-COINS-F")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "bagOfCoinsFunc()",
            type: .void
        ))
    }

    func testProcessRoutineOneParam() throws {
        let symbol = try Factories.RoutineCall([
            .atom("ONE-FCN"),
            .decimal(42)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "oneFunc(number: 42)",
            type: .int
        ))
    }

    func testProcessRoutineTwoParams() throws {
        let symbol = try Factories.RoutineCall([
            .atom("TWO-F"),
            .string("Answer"),
            .decimal(42),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                twoFunc(
                    answer: \"Answer\",
                    number: 42
                )
                """,
            type: .string
        ))
    }

    func testProcessRoutineThreeParams() throws {
        let symbol = try Factories.RoutineCall([
            .atom("THREE-FUNCTION"),
            .string("Answer"),
            .bool(true),
            .form([
                .atom("ONE-FCN"),
                .decimal(42),
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                threeFunc(
                    answer: \"Answer\",
                    isValid: true,
                    number: oneFunc(number: 42)
                )
                """,
            type: .string
        ))
    }
}
