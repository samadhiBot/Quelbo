//
//  EqualsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class EqualsTests: QuelboTests {
    let factory = Factories.Equals.self

//    override func setUp() {
//        super.setUp()
//
//        Game.commit(
//            Symbol(id: "isPlayerAlive", type: .bool, category: .globals),
//            Symbol(id: "isWorldAlive", type: .bool, category: .globals)
//        )
//    }

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
            code: "2.equals(3)",
            type: .bool
        ))
    }

    func testEqualAtomAndDecimal() throws {
        let registry: Set<Symbol> = [Symbol(id: "n", type: .int)]

        let symbol = try factory.init([
            .local("N"),
            .decimal(3),
        ], with: registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "n.equals(3)",
            type: .bool
        ))
    }

    func testEqualThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
            .decimal(4),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "2.equals(3, 4)",
            type: .bool
        ))
    }

    func testEqualTwoStrings() throws {
        let symbol = try factory.init([
            .string("hello"),
            .string("goodBye"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: #""hello".equals("goodBye")"#,
            type: .bool
        ))
    }

    func testEqualTwoGlobalBools() throws {
        let _ = try Factories.Global([.atom("PLAYER-ALIVE?"), .bool(true)]).process()
        let _ = try Factories.Global([.atom("WORLD-ALIVE?"), .bool(true)]).process()

        let symbol = try factory.init([
            .global("PLAYER-ALIVE?"),
            .global("WORLD-ALIVE?"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "isPlayerAlive.equals(isWorldAlive)",
            type: .bool
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
