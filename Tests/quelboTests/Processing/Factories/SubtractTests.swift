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
                category: .routines
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
            Variable(id: "foo", type: .int)
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
            code: ".subtract(9, 3)",
            type: .int
        ))
    }

    func testSubtractThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(20),
            .decimal(5),
            .decimal(2),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".subtract(20, 5, 2)",
            type: .int
        ))
    }

    func testSubtractTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "bigNumber.subtract(biggerNumber)",
            type: .int
        ))
    }

    func testSubtractAtomAndDecimal() throws {
        let symbol = try factory.init([
            .global("CYCLOWRATH"),
            .decimal(1),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "cyclowrath.subtract(1)",
            type: .int
        ))
    }

    func testSubtractAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .global("BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "baseScore.subtract(otvalFrob())",
            type: .int
        ))
    }
}
