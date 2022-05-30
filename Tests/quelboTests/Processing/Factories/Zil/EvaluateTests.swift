//
//  EvaluateTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class EvaluateTests: QuelboTests {
    override func setUp() {
        super.setUp()

        try! Game.commit(
            Symbol(
                "bagOfCoinsFunc",
                type: .void,
                category: .routines
            ),
            Symbol(
                "oneFunc",
                type: .int,
                category: .routines,
                children: [
                    Symbol(id: "number", type: .int, meta: [.isLiteral])
                ]
            ),
            Symbol(
                "twoFunc",
                type: .string,
                category: .routines,
                children: [
                    Symbol("answer", type: .string, meta: [.isLiteral]),
                    Symbol("number", type: .int, meta: [.isLiteral]),
                ]
            ),
            Symbol(
                "threeFunc",
                type: .string,
                category: .routines,
                children: [
                    Symbol("answer", type: .string, meta: [.isLiteral]),
                    Symbol("isValid", type: .bool),
                    Symbol("number", type: .int, meta: [.isLiteral]),
                ]
            )
        )
    }

    func testProcessRoutineZeroParams() throws {
        let symbol = try Factories.Evaluate.init([
            .atom("BAG-OF-COINS-F")
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "bagOfCoinsFunc",
            code: "bagOfCoinsFunc()",
            type: .void
        ))
    }

    func testProcessRoutineOneParam() throws {
        let symbol = try Factories.Evaluate.init([
            .atom("ONE-FCN"),
            .decimal(42)
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "oneFunc",
            code: "oneFunc(number: 42)",
            type: .int,
            children: [
                Symbol(id: "number", code: "number: 42", type: .int, meta: [.isLiteral])
            ]
        ))
    }

    func testProcessRoutineTwoParams() throws {
        let symbol = try Factories.Evaluate.init([
            .atom("TWO-F"),
            .string("Answer"),
            .decimal(42),
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "twoFunc",
            code: """
                twoFunc(
                    answer: \"Answer\",
                    number: 42
                )
                """,
            type: .string,
            children: [
                Symbol(id: "answer", code: #"answer: "Answer""#, type: .string, meta: [.isLiteral]),
                Symbol(id: "number", code: "number: 42", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testProcessRoutineThreeParams() throws {
        let symbol = try Factories.Evaluate.init([
            .atom("THREE-FUNCTION"),
            .string("Answer"),
            .bool(true),
            .form([
                .atom("ONE-FCN"),
                .decimal(42),
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "threeFunc",
            code: """
                threeFunc(
                    answer: \"Answer\",
                    isValid: true,
                    number: oneFunc(number: 42)
                )
                """,
            type: .string,
            children: [
                Symbol(id: "answer", code: #"answer: "Answer""#, type: .string, meta: [.isLiteral]),
                Symbol(id: "isValid", code: "isValid: true", type: .bool),
                Symbol(id: "number", code: "number: oneFunc(number: 42)", type: .int, meta: [.isLiteral]),
            ]
        ))
    }
}
