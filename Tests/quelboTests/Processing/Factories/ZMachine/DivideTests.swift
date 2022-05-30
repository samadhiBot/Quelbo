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

        try! Game.commit(
            Symbol("baseScore", type: .int, category: .globals),
            Symbol("cyclowrath", type: .int, category: .globals),
            Symbol("myBike", type: .string, category: .globals),
            Symbol("otvalFrob", type: .int, category: .routines)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("/"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("DIV"))
    }

    func testDivideTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(9),
            .decimal(3),
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".divide(9, 3)",
            type: .int,
            children: [
                Symbol("9", type: .int, meta: [.isLiteral]),
                Symbol("3", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testDivideThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(20),
            .decimal(5),
            .decimal(2),
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".divide(20, 5, 2)",
            type: .int,
            children: [
                Symbol("20", type: .int, meta: [.isLiteral]),
                Symbol("5", type: .int, meta: [.isLiteral]),
                Symbol("2", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testDivideTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            "bigNumber.divide(biggerNumber)",
            type: .int,
            children: [
                Symbol("bigNumber", type: .int, meta: [.mutating(true)]),
                Symbol("biggerNumber", type: .int),
            ]
        ))
    }

    func testDivideAtomAndDecimal() throws {
        let symbol = try factory.init([
            .global("CYCLOWRATH"),
            .decimal(1),
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            "cyclowrath.divide(1)",
            type: .int,
            children: [
                Symbol("cyclowrath", type: .int, category: .globals, meta: [.mutating(true)]),
                Symbol("1", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testDivideAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .global("BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            "baseScore.divide(otvalFrob())",
            type: .int,
            children: [
                Symbol("baseScore", type: .int, category: .globals, meta: [.mutating(true)]),
                Symbol(id: "otvalFrob", code: "otvalFrob()", type: .int),
            ]
        ))
    }


    func testDivideOneDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ], with: types)
        )
    }
}
