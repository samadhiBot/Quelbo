//
//  EqualTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class EqualTests: QuelboTests {
    let factory = Factories.Equals.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
            Symbol("isPlayerAlive", type: .bool, category: .globals),
            Symbol("isWorldAlive", type: .bool, category: .globals)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("=?"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("==?"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("EQUAL?"))
    }

    func testEqualTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.equals(3)",
            type: .bool,
            children: [
                Symbol("2", type: .int),
                Symbol("3", type: .int),
            ]
        ))
    }

    func testEqualAtomAndDecimal() throws {
        let symbol = try factory.init([
            .atom(".N"),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "n.equals(3)",
            type: .bool,
            children: [
                Symbol("n", type: .int),
                Symbol("3", type: .int),
            ]
        ))
    }

    func testEqualThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
            .decimal(4),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.equals(3, 4)",
            type: .bool,
            children: [
                Symbol("2", type: .int),
                Symbol("3", type: .int),
                Symbol("4", type: .int),
            ]
        ))
    }

    func testEqualTwoStrings() throws {
        let symbol = try factory.init([
            .string("hello"),
            .string("goodBye"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: #""hello".equals("goodBye")"#,
            type: .bool,
            children: [
                Symbol(id: #""hello""#, type: .string),
                Symbol(id: #""goodBye""#, type: .string),
            ]
        ))
    }

    func testEqualTwoGlobalBools() throws {
        let symbol = try factory.init([
            .atom(",PLAYER-ALIVE?"),
            .atom(",WORLD-ALIVE?"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "isPlayerAlive.equals(isWorldAlive)",
            type: .bool,
            children: [
                Symbol("isPlayerAlive", type: .bool, category: .globals),
                Symbol("isWorldAlive", type: .bool, category: .globals),
            ]
        ))
    }

    func testEqualOneArgument() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
            ])
        )
    }

    func testEqualOneDecimalOneString() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .string("3"),
            ])
        )
    }
}
