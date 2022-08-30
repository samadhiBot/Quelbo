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

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("=?"))
        AssertSameFactory(factory, Game.findFactory("==?"))
        AssertSameFactory(factory, Game.findFactory("EQUAL?"))
    }

    func testEqualTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.equals(3)",
            type: .bool,
            confidence: .certain
        ))
    }

    func testEqualAtomAndDecimal() throws {
        localVariables.append(
            Variable(id: "n", type: .int)
        )

        let symbol = try factory.init([
            .local("N"),
            .decimal(3),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "n.equals(3)",
            type: .bool,
            confidence: .certain
        ))
    }

    func testEqualThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
            .decimal(4),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.equals(3, 4)",
            type: .bool,
            confidence: .certain
        ))
    }

    func testEqualTwoStrings() throws {
        let symbol = try factory.init([
            .string("hello"),
            .string("goodBye"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #""hello".equals("goodBye")"#,
            type: .bool,
            confidence: .certain
        ))
    }

    func testEqualTwoGlobalBools() throws {
        try Factories.Global([
            .atom("PLAYER-ALIVE?"),
            .bool(true)
        ], with: &localVariables).process()

        try Factories.Global([
            .atom("WORLD-ALIVE?"),
            .bool(true)
        ], with: &localVariables).process()

        let symbol = try factory.init([
            .global("PLAYER-ALIVE?"),
            .global("WORLD-ALIVE?"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "isPlayerAlive.equals(isWorldAlive)",
            type: .bool,
            confidence: .certain
        ))
    }

    func testEqualOneArgument() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
            ], with: &localVariables)
        )
    }

    func testEqualOneDecimalOneString() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .string("3"),
            ], with: &localVariables)
        )
    }
}
