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
                category: .routines,
                isCommittable: true
            ),
            .statement(
                id: "oneFunc",
                code: "",
                type: .int,
                parameters: [
                    Instance(Variable(id: "number", type: .int)),
                ],
                category: .routines,
                isCommittable: true
            ),
            .statement(
                id: "twoFunc",
                code: "",
                type: .string,
                parameters: [
                    Instance(Variable(id: "answer", type: .string)),
                    Instance(Variable(id: "number", type: .int)),
                ],
                category: .routines,
                isCommittable: true
            ),
            .statement(
                id: "threeFunc",
                code: "",
                type: .string,
                parameters: [
                    Instance(Variable(id: "answer", type: .string)),
                    Instance(Variable(id: "isValid", type: .bool)),
                    Instance(Variable(id: "number", type: .int)),
                ],
                category: .routines,
                isCommittable: true
            )
        ])
    }

    func testProcessRoutineZeroParams() throws {
        let symbol = try Factories.RoutineCall([
            .atom("BAG-OF-COINS-F")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "bagOfCoinsFunc",
            code: "bagOfCoinsFunc()",
            type: .void
        ))
    }

    func testProcessRoutineOneParam() throws {
        let symbol = try Factories.RoutineCall([
            .atom("ONE-FCN"),
            .decimal(42)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "oneFunc",
            code: "oneFunc(number: 42)",
            type: .int
        ))
    }

    func testProcessRoutineTwoParams() throws {
        let symbol = try Factories.RoutineCall([
            .atom("TWO-F"),
            .string("Answer"),
            .decimal(42),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "twoFunc",
            code: """
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "threeFunc",
            code: """
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
