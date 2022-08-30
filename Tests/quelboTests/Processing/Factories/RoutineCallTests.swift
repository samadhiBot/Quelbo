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

        try! Game.commit([
            .statement(
                id: "bagOfCoinsFunc",
                code: "",
                type: .void,
                confidence: .void,
                category: .routines
            ),
            .statement(
                id: "oneFunc",
                code: "",
                type: .int,
                confidence: .certain,
                parameters: [
                    Instance(Variable(id: "number", type: .int, confidence: .certain)),
                ],
                category: .routines
            ),
            .statement(
                id: "twoFunc",
                code: "",
                type: .string,
                confidence: .certain,
                parameters: [
                    Instance(Variable(id: "answer", type: .string, confidence: .certain)),
                    Instance(Variable(id: "number", type: .int, confidence: .certain)),
                ],
                category: .routines
            ),
            .statement(
                id: "threeFunc",
                code: "",
                type: .string,
                confidence: .certain,
                parameters: [
                    Instance(Variable(id: "answer", type: .string, confidence: .certain)),
                    Instance(Variable(id: "isValid", type: .bool, confidence: .certain)),
                    Instance(Variable(id: "number", type: .int, confidence: .certain)),
                ],
                category: .routines
            )
        ])
    }

    func testProcessRoutineZeroParams() throws {
        let symbol = try Factories.RoutineCall([
            .atom("BAG-OF-COINS-F")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "bagOfCoinsFunc()",
            type: .void,
            confidence: .void
        ))
    }

    func testProcessRoutineOneParam() throws {
        let symbol = try Factories.RoutineCall([
            .atom("ONE-FCN"),
            .decimal(42)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "oneFunc(number: 42)",
            type: .int,
            confidence: .certain
        ))
    }

    func testProcessRoutineTwoParams() throws {
        let symbol = try Factories.RoutineCall([
            .atom("TWO-F"),
            .string("Answer"),
            .decimal(42),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                twoFunc(
                    answer: \"Answer\",
                    number: 42
                )
                """,
            type: .string,
            confidence: .certain
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                threeFunc(
                    answer: \"Answer\",
                    isValid: true,
                    number: oneFunc(number: 42)
                )
                """,
            type: .string,
            confidence: .certain
        ))
    }
}
