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
            Symbol("baseScore", type: .int, category: .globals),
            Symbol("cyclowrath", type: .int, category: .globals),
            Symbol("myBike", type: .string, category: .globals),
            Symbol("otvalFrob", type: .int, category: .routines)
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
            type: .int,
            children: [
                Symbol("42", type: .int, literal: true),
            ]
        ))
    }

    func testSubtractOneAtom() throws {
        let symbol = try factory.init([
            .atom(".FOO"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "-foo",
            type: .int,
            children: [
                Symbol("foo", type: .int),
            ]
        ))
    }

    func testSubtractTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(9),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".subtract(9, 3)",
            type: .int,
            children: [
                Symbol("9", type: .int, literal: true),
                Symbol("3", type: .int, literal: true),
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
            ".subtract(20, 5, 2)",
            type: .int,
            children: [
                Symbol("20", type: .int, literal: true),
                Symbol("5", type: .int, literal: true),
                Symbol("2", type: .int, literal: true),
            ]
        ))
    }

    func testSubtractTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "bigNumber.subtract(biggerNumber)",
            type: .int,
            children: [
                Symbol(id: "bigNumber", type: .int),
                Symbol(id: "biggerNumber", type: .int),
            ]
        ))
    }

    func testSubtractAtomAndDecimal() throws {
        let symbol = try factory.init([
            .atom(",CYCLOWRATH"),
            .decimal(1),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "cyclowrath.subtract(1)",
            type: .int,
            children: [
                Symbol(id: "cyclowrath", type: .int, category: .globals),
                Symbol(id: "1", type: .int, literal: true),
            ]
        ))
    }

    func testSubtractAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .atom(",BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "baseScore.subtract(otvalFrob())",
            type: .int,
            children: [
                Symbol(id: "baseScore", type: .int, category: .globals),
                Symbol(id: "otvalFrob", code: "otvalFrob()", type: .int),
            ]
        ))
    }
}
