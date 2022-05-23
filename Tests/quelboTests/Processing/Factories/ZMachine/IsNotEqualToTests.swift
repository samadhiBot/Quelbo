//
//  IsNotEqualToTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsNotEqualToTests: QuelboTests {
    let factory = Factories.IsNotEqualTo.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
            Symbol("isPlayerAlive", type: .bool, category: .globals),
            Symbol("isWorldAlive", type: .bool, category: .globals)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("N==?"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("N=?"))
    }

    func testEqualTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.isNotEqualTo(3)",
            type: .bool,
            children: [
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol("3", type: .int, meta: [.isLiteral]),
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
            "2.isNotEqualTo(3, 4)",
            type: .bool,
            children: [
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol("3", type: .int, meta: [.isLiteral]),
                Symbol("4", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testEqualTwoStrings() throws {
        let symbol = try factory.init([
            .string("hello"),
            .string("goodBye"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #""hello".isNotEqualTo("goodBye")"#,
            type: .bool,
            children: [
                Symbol(#""hello""#, type: .string, meta: [.isLiteral]),
                Symbol(#""goodBye""#, type: .string, meta: [.isLiteral]),
            ]
        ))
    }

    func testEqualTwoGlobalBools() throws {
        let symbol = try factory.init([
            .global("PLAYER-ALIVE?"),
            .global("WORLD-ALIVE?"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "isPlayerAlive.isNotEqualTo(isWorldAlive)",
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
