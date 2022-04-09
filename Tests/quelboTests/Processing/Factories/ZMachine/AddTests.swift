//
//  AddTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class AddTests: QuelboTests {
    let factory = Factories.Add.self

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
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("+"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("ADD"))
    }

    func testAddTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "2.add(3)",
            type: .int,
            children: [
                Symbol(id: "2", type: .int),
                Symbol(id: "3", type: .int),
            ]
        ))
    }

    func testAddThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
            .decimal(4),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "2.add(3, 4)",
            type: .int,
            children: [
                Symbol(id: "2", type: .int),
                Symbol(id: "3", type: .int),
                Symbol(id: "4", type: .int),
            ]
        ))
    }

    func testAddTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "bigNumber.add(biggerNumber)",
            type: .int,
            children: [
                Symbol(id: "bigNumber", type: .int),
                Symbol(id: "biggerNumber", type: .int),
            ]
        ))
    }

    func testAddAtomAndDecimal() throws {
        let symbol = try factory.init([
            .atom(",CYCLOWRATH"),
            .decimal(1),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "cyclowrath.add(1)",
            type: .int,
            children: [
                Symbol(id: "cyclowrath", type: .int, category: .globals),
                Symbol(id: "1", type: .int),
            ]
        ))
    }

    func testAddAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .atom(",BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "baseScore.add(otvalFrob())",
            type: .int,
            children: [
                Symbol(id: "baseScore", type: .int, category: .globals),
                Symbol(id: "otvalFrob", code: "otvalFrob()", type: .int),
            ]
        ))
    }

    func testAddOneDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ])
        )
    }

    func testAddDecimalAndBoolThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .bool(true),
            ])
        )
    }

    func testAddDecimalAndStringThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .string("💣"),
            ])
        )
    }

    func testAddDecimalAndStringGlobalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .atom(",MY-BIKE"),
            ])
        )
    }
}
