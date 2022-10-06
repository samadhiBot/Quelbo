//
//  BitwiseAndTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class BitwiseAndTests: QuelboTests {
    let factory = Factories.BitwiseAnd.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("BAND"))
        AssertSameFactory(factory, Game.findFactory("ANDB"))
    }

    func testBitwiseAnd() throws {
        process("<GLOBAL SOME-INT 42>")

        let symbol = try factory.init([
            .decimal(1),
            .decimal(0),
            .decimal(2),
            .global("SOME-INT"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".bitwiseAnd(1, 0, 2, someInt)",
            type: .int
        ))
    }

    func testNonIntegerThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .decimal(0),
                .string("three"),
            ], with: &localVariables).process()
        )
    }
}
