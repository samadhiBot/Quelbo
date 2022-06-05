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
            Symbol("baseScore", type: .int, category: .globals),
            Symbol("cyclowrath", type: .int, category: .globals),
            Symbol("myBike", type: .string, category: .globals),
            Symbol("otvalFrob", type: .int, category: .routines)
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
            type: .int,
            children: [
                Symbol("9", type: .int, meta: [.isLiteral]),
                Symbol("3", type: .int, meta: [.isLiteral]),
            ]
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
            type: .int,
            children: [
                Symbol("20", type: .int, meta: [.isLiteral]),
                Symbol("5", type: .int, meta: [.isLiteral]),
                Symbol("2", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testMultiplyTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "bigNumber.multiply(biggerNumber)",
            type: .int,
            children: [
                Symbol("bigNumber", type: .int, meta: [.mutating(true)]),
                Symbol("biggerNumber", type: .int),
            ]
        ))
    }

    func testMultiplyAtomAndDecimal() throws {
        let symbol = try factory.init([
            .global("CYCLOWRATH"),
            .decimal(1),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "cyclowrath.multiply(1)",
            type: .int,
            children: [
                Symbol("cyclowrath", type: .int, category: .globals, meta: [.mutating(true)]),
                Symbol("1", type: .int, meta: [.isLiteral]),
            ]
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
            type: .int,
            children: [
                Symbol("baseScore", type: .int, category: .globals, meta: [.mutating(true)]),
                Symbol("otvalFrob()", type: .int),
            ]
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
