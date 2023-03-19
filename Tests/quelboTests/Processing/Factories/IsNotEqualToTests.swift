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

        try! Game.commit([
            .variable(id: "isPlayerAlive", type: .bool, category: .globals),
            .variable(id: "isWorldAlive", type: .bool, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("N==?"))
        AssertSameFactory(factory, Game.findFactory("N=?"))
    }

    func testEqualTwoDecimals() throws {
        let symbol = process("<N==? 2 3>")

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isNotEqualTo(3)",
            type: .bool
        ))
    }

    func testEvaluation() throws {
        XCTAssertNoDifference(
            process("<N=? 2 1>", mode: .evaluate),
            .true
        )

        XCTAssertNoDifference(
            process("<N=? \"foo\" \"bar\">", mode: .evaluate),
            .true
        )

        XCTAssertNoDifference(
            process("<N=? 2 2 2>", mode: .evaluate),
            .false
        )

        XCTAssertNoDifference(
            process("<N=? \"foo\" \"foo\">", mode: .evaluate),
            .false
        )
    }

    func testEqualThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
            .decimal(4),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isNotEqualTo(3, 4)",
            type: .bool
        ))
    }

    func testEqualTwoStrings() throws {
        let symbol = try factory.init([
            .string("hello"),
            .string("goodBye"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #""hello".isNotEqualTo("goodBye")"#,
            type: .bool
        ))
    }

    func testEqualTwoGlobalBools() throws {
        let symbol = try factory.init([
            .global(.atom("PLAYER-ALIVE?")),
            .global(.atom("WORLD-ALIVE?")),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Globals.isPlayerAlive.isNotEqualTo(Globals.isWorldAlive)",
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
                .commented(.string("3")),
            ], with: &localVariables)
        )
    }
}
