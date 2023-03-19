//
//  DivideTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DivideTests: QuelboTests {
    let factory = Factories.Divide.self

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
                category: .routines,
                isCommittable: true
            )
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("/"))
        AssertSameFactory(factory, Game.findFactory("DIV"))
    }

    func testDivideTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(9),
            .decimal(3),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".divide(9, 3)",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testDivideThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(20),
            .decimal(5),
            .decimal(2),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".divide(20, 5, 2)",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testDivideTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".divide(bigNumber, biggerNumber)",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testDivideAtomAndDecimal() throws {
        let symbol = try factory.init([
            .global(.atom("CYCLOWRATH")),
            .decimal(1),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".divide(Globals.cyclowrath, 1)",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testDivideAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .global(.atom("BASE-SCORE")),
            .form([
                .atom("OTVAL-FROB")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".divide(Globals.baseScore, otvalFrob())",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testDivideOneDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ], with: &localVariables)
        )
    }

    func testEvaluate() throws {
        XCTAssertNoDifference(
            evaluate("</ 100 5 2>"),
            .literal(10)
        )

        XCTAssertNoDifference(
            process("<PRINTN %</ 100 5 2>>"),
            .statement(
                code: "output(10)",
                type: .void
            )
        )
    }
}
