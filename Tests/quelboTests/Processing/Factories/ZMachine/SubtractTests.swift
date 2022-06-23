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

        try! Game.commit(
            Symbol(id: "baseScore", type: .int, category: .globals),
            Symbol(id: "cyclowrath", type: .int, category: .globals),
            Symbol(id: "myBike", type: .string, category: .globals),
            Symbol(id: "otvalFrob", type: .int, category: .routines)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("-"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("SUB"))
    }

    func testSubtractOneDecimal() throws {
        let symbol = try factory.init([
            .decimal(42),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "-42",
            type: .int
        ))
    }

    func testSubtractOneAtom() throws {
        let symbol = try factory.init([
            .local("FOO"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "-foo",
            type: .int
        ))
    }

    func testSubtractTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(9),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".subtract(9, 3)",
            type: .int
        ))
    }

    func testSubtractThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(20),
            .decimal(5),
            .decimal(2),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".subtract(20, 5, 2)",
            type: .int
        ))
    }

    func testSubtractTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "bigNumber.subtract(biggerNumber)",
            type: .int
        ))
    }

    func testSubtractAtomAndDecimal() throws {
        let symbol = try factory.init([
            .global("CYCLOWRATH"),
            .decimal(1),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "cyclowrath.subtract(1)",
            type: .int
        ))
    }

    func testSubtractAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .global("BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "baseScore.subtract(otvalFrob())",
            type: .int
        ))
    }
}
