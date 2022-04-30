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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: ".divide(9, 3)",
            type: .int,
            children: [
                Symbol(id: "9", type: .int, literal: true),
                Symbol(id: "3", type: .int, literal: true),
            ]
        ))
    }

    func testDivideThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(20),
            .decimal(5),
            .decimal(2),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: ".divide(20, 5, 2)",
            type: .int,
            children: [
                Symbol(id: "20", type: .int, literal: true),
                Symbol(id: "5", type: .int, literal: true),
                Symbol(id: "2", type: .int, literal: true),
            ]
        ))
    }

    func testDivideTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "bigNumber.divide(biggerNumber)",
            type: .int,
            children: [
                Symbol(id: "bigNumber", type: .int),
                Symbol(id: "biggerNumber", type: .int),
            ]
        ))
    }

    func testDivideAtomAndDecimal() throws {
        let symbol = try factory.init([
            .atom(",CYCLOWRATH"),
            .decimal(1),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "cyclowrath.divide(1)",
            type: .int,
            children: [
                Symbol(id: "cyclowrath", type: .int, category: .globals),
                Symbol(id: "1", type: .int, literal: true),
            ]
        ))
    }

    func testDivideAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .atom(",BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "baseScore.divide(otvalFrob())",
            type: .int,
            children: [
                Symbol(id: "baseScore", type: .int, category: .globals),
                Symbol(id: "otvalFrob", code: "otvalFrob()", type: .int),
            ]
        ))
    }


    func testDivideOneDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ])
        )
    }
}
