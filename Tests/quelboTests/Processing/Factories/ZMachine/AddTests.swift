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
            Symbol(id: "baseScore", type: .int, category: .globals),
            Symbol(id: "cyclowrath", type: .int, category: .globals),
            Symbol(id: "myBike", type: .string, category: .globals),
            Symbol(id: "otvalFrob", type: .int, category: .routines)
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
            ".add(2, 3)",
            type: .int,
            children: [
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol("3", type: .int, meta: [.isLiteral]),
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
            ".add(2, 3, 4)",
            type: .int,
            children: [
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol("3", type: .int, meta: [.isLiteral]),
                Symbol("4", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testAddTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "bigNumber.add(biggerNumber)",
            type: .int,
            children: [
                Symbol("bigNumber", type: .int, meta: [.mutating(true)]),
                Symbol("biggerNumber", type: .int),
            ]
        ))
    }

    func testAddAtomAndDecimal() throws {
        let symbol = try factory.init([
            .global("CYCLOWRATH"),
            .decimal(1),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "cyclowrath.add(1)",
            type: .int,
            children: [
                Symbol("cyclowrath", type: .int, category: .globals, meta: [.mutating(true)]),
                Symbol("1", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testAddAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .global("BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "baseScore.add(otvalFrob())",
            type: .int,
            children: [
                Symbol("baseScore", type: .int, category: .globals, meta: [.mutating(true)]),
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
                .global("MY-BIKE"),
            ])
        )
    }
}
