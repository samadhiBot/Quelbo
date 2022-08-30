//
//  MultiplyTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class MultiplyTests: QuelboTests {
    let factory = Factories.Multiply.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "baseScore", type: .int, category: .globals),
            .variable(id: "cyclowrath", type: .int, category: .globals),
            .variable(id: "myBike", type: .string, category: .globals),
            .statement(
                id: "otvalFrob",
                code: "",
                type: .int,
                confidence: .certain,
                category: .routines
            )
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("*"))
        AssertSameFactory(factory, Game.findFactory("MUL"))
    }

    func testMultiplyTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(9),
            .decimal(3),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".multiply(9, 3)",
            type: .int,
            confidence: .certain
        ))
    }

    func testMultiplyThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(20),
            .decimal(5),
            .decimal(2),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".multiply(20, 5, 2)",
            type: .int,
            confidence: .certain
        ))
    }

    func testMultiplyTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "bigNumber.multiply(biggerNumber)",
            type: .int,
            confidence: .certain
        ))
    }

    func testMultiplyAtomAndDecimal() throws {
        let symbol = try factory.init([
            .global("CYCLOWRATH"),
            .decimal(1),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "cyclowrath.multiply(1)",
            type: .int,
            confidence: .certain
        ))
    }

    func testMultiplyAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .global("BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "baseScore.multiply(otvalFrob())",
            type: .int,
            confidence: .certain
        ))
    }

    func testMultiplyOneDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ], with: &localVariables)
        )
    }
}
