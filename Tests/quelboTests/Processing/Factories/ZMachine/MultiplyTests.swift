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

        try! Game.commit(
            Symbol(id: "baseScore", type: .int, category: .globals),
            Symbol(id: "cyclowrath", type: .int, category: .globals),
            Symbol(id: "myBike", type: .string, category: .globals),
            Symbol(id: "otvalFrob", type: .int, category: .routines)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("*"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("MUL"))
    }

    func testMultiplyTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(9),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".multiply(9, 3)",
            type: .int
        ))
    }

    func testMultiplyThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(20),
            .decimal(5),
            .decimal(2),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".multiply(20, 5, 2)",
            type: .int
        ))
    }

    func testMultiplyTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "bigNumber.multiply(biggerNumber)",
            type: .int
        ))
    }

    func testMultiplyAtomAndDecimal() throws {
        let symbol = try factory.init([
            .global("CYCLOWRATH"),
            .decimal(1),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "cyclowrath.multiply(1)",
            type: .int
        ))
    }

    func testMultiplyAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .global("BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "baseScore.multiply(otvalFrob())",
            type: .int
        ))
    }

    func testMultiplyOneDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ])
        )
    }
}
