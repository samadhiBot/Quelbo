//
//  SubtractTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SubtractTests: QuelboTests {
    let factory = Factories.Subtract.self

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
        AssertSameFactory(factory, Game.findFactory("-"))
        AssertSameFactory(factory, Game.findFactory("SUB"))
    }

    func testSubtractOneDecimal() throws {
        let symbol = try factory.init([
            .decimal(42),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "-42",
            type: .int
        ))
    }

    func testSubtractOneAtom() throws {
        localVariables.append(
            Statement(id: "foo", type: .int)
        )

        let symbol = try factory.init([
            .local("FOO"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "-foo",
            type: .int
        ))
    }

    func testSubtractTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(9),
            .decimal(3),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "9.subtract(3)",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testSubtractThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(20),
            .decimal(5),
            .decimal(2),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "20.subtract(5, 2)",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testSubtractTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "bigNumber.subtract(biggerNumber)",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testSubtractAtomAndDecimal() throws {
        let symbol = try factory.init([
            .global(.atom("CYCLOWRATH")),
            .decimal(1),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Globals.cyclowrath.subtract(1)",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testSubtractAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .global(.atom("BASE-SCORE")),
            .form([
                .atom("OTVAL-FROB")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Globals.baseScore.subtract(otvalFrob())",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testEvaluate() throws {
        XCTAssertNoDifference(
            evaluate("<- 10 3 2>"),
            .literal(5)
        )

        XCTAssertNoDifference(
            process("<PRINTN %<- 10 3 2>>"),
            .statement(
                code: "output(5)",
                type: .void
            )
        )
    }

    func testEvaluateIntoNegative() throws {
        XCTAssertNoDifference(
            evaluate("<- 10 11 12>"),
            .literal(-13)
        )

        XCTAssertNoDifference(
            process("<PRINTN %<- 10 11 12>>"),
            .statement(
                code: "output(-13)",
                type: .void
            )
        )
    }

    func testEvaluateOneDecimal() throws {
        XCTAssertNoDifference(
            evaluate("<- 42>"),
            .literal(-42)
        )

        XCTAssertNoDifference(
            process("<PRINTN %<- 42>>"),
            .statement(
                code: "output(-42)",
                type: .void
            )
        )
    }
}
