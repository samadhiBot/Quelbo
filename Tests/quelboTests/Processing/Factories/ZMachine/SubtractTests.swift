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
            type: .int,
            children: [
                Symbol("42", type: .int),
            ]
        ))
    }

    func testSubtractTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(9),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "9.subtract(3)",
            type: .int,
            children: [
                Symbol("9", type: .int),
                Symbol("3", type: .int),
            ]
        ))
    }

    func testSubtractThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(20),
            .decimal(5),
            .decimal(2),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "20.subtract(5, 2)",
            type: .int,
            children: [
                Symbol("20", type: .int),
                Symbol("5", type: .int),
                Symbol("2", type: .int),
            ]
        ))
    }
}
