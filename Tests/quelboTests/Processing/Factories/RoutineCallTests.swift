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
                payload: .init(
                    parameters: [
                        Instance(Statement(id: "number", type: .int)),
                    ]
                ),
                category: .routines,
                isCommittable: true
            ),
            .statement(
                id: "twoFunc",
                code: "",
                type: .string,
                payload: .init(
                    parameters: [
                        Instance(Statement(id: "answer", type: .string)),
                        Instance(Statement(id: "number", type: .int)),
                    ]
                ),
                category: .routines,
                isCommittable: true
            ),
            .statement(
                id: "threeFunc",
                code: "",
                type: .string,
                payload: .init(
                    parameters: [
                        Instance(Statement(id: "answer", type: .string)),
                        Instance(Statement(id: "isValid", type: .bool)),
                        Instance(Statement(id: "number", type: .int)),
                    ]
                ),
                category: .routines,
                isCommittable: true
            ),
            .statement(
                id: "throwingFunc",
                code: "",
                type: .string,
                payload: .init(
                    parameters: [
                        Instance(Statement(id: "key", type: .int)),
                    ]
                ),
                category: .routines,
                isCommittable: true,
                isThrowing: true
            ),
        ])
    }

    func testProcessRoutineZeroParams() throws {
        let symbol = try Factories.RoutineCall([
            .atom("BAG-OF-COINS-F")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "bagOfCoinsFunc",
            code: "bagOfCoinsFunc()",
            type: .void,
            returnHandling: .implicit
        ))
    }

    func testProcessRoutineOneParam() throws {
        let symbol = process("<ONE-FCN 42>")

        XCTAssertNoDifference(symbol, .statement(
            id: "oneFunc",
            code: "oneFunc(number: 42)",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testProcessRoutineTwoParams() throws {
        let symbol = process("""
            <TWO-F "Answer" 42>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "twoFunc",
            code: """
                twoFunc(answer: "Answer", number: 42)
                """,
            type: .string,
            returnHandling: .implicit
        ))
    }

    func testProcessRoutineThreeParams() throws {
        let symbol = process("""
            <THREE-FUNCTION "Answer" T <ONE-FCN 42>>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "threeFunc",
            code: """
                threeFunc(
                    answer: \"Answer\",
                    isValid: true,
                    number: oneFunc(number: 42)
                )
                """,
            type: .string,
            returnHandling: .implicit
        ))
    }

    func testProcessThrowingRoutine() throws {
        let symbol = process("<THROWING-FCN 42>")

        XCTAssertNoDifference(symbol, .statement(
            id: "throwingFunc",
            code: "try throwingFunc(key: 42)",
            type: .string,
            isThrowing: true,
            returnHandling: .implicit
        ))
    }

    func testProcessThrowingRoutineThreeParams() throws {
        let symbol = process("""
            <THREE-FUNCTION "Answer" T <THROWING-FCN 42>>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "threeFunc",
            code: """
                threeFunc(
                    answer: \"Answer\",
                    isValid: true,
                    number: try throwingFunc(key: 42)
                )
                """,
            type: .string,
            returnHandling: .implicit
        ))
    }
}
