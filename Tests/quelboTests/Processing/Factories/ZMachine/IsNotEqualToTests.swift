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
                Symbol("2", type: .int, literal: true),
                Symbol("3", type: .int, literal: true),
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
                Symbol("2", type: .int, literal: true),
                Symbol("3", type: .int, literal: true),
                Symbol("4", type: .int, literal: true),
            ]
        ))
    }

    func testEqualTwoStrings() throws {
        let symbol = try factory.init([
            .string("hello"),
            .string("goodBye"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: #""hello".isNotEqualTo("goodBye")"#,
            type: .bool,
            children: [
                Symbol(id: #""hello""#, type: .string, literal: true),
                Symbol(id: #""goodBye""#, type: .string, literal: true),
            ]
        ))
    }

    func testEqualTwoGlobalBools() throws {
        let symbol = try factory.init([
            .atom(",PLAYER-ALIVE?"),
            .atom(",WORLD-ALIVE?"),
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
