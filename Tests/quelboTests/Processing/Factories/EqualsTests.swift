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
        let symbol = process("<EQUAL? 2 3>")

        XCTAssertNoDifference(symbol, .statement(
            code: "2.equals(3)",
            type: .bool
        ))
    }

    func testEvaluation() throws {
        XCTAssertNoDifference(
            process("<=? 1 1>", mode: .evaluate),
            .true
        )

        XCTAssertNoDifference(
            process("<==? 1 2>", mode: .evaluate),
            .false
        )

        XCTAssertNoDifference(
            process("<EQUAL? 2 1>", mode: .evaluate),
            .false
        )
    }

    func testEqualAtomAndDecimal() throws {
        localVariables.append(
            Statement(id: "n", type: .int)
        )

        let symbol = try factory.init([
            .local("N"),
            .decimal(3),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "n.equals(3)",
            type: .bool
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
            type: .bool
        ))
    }

    func testEqualTwoStrings() throws {
        let symbol = try factory.init([
            .string("hello"),
            .string("goodBye"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #""hello".equals("goodBye")"#,
            type: .bool
        ))
    }

    func testEqualTwoGlobalBools() throws {
        process("<GLOBAL PLAYER-ALIVE? T>")
        process("<GLOBAL WORLD-ALIVE? T>")

        let symbol = try factory.init([
            .global(.atom("PLAYER-ALIVE?")),
            .global(.atom("WORLD-ALIVE?")),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Global.isPlayerAlive.equals(Global.isWorldAlive)",
            type: .bool
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
                .commented(.string("3"))
            ], with: &localVariables)
        )
    }
}
