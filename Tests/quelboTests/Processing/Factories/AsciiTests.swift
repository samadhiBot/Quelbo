//
//  AsciiTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class AsciiTests: QuelboTests {
    let factory = Factories.Ascii.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ASCII"))
    }

    func testAsciiCharacterToDecimal() throws {
        let symbol = try factory.init([
            .character("A")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "\"A\".ascii",
            type: .int
        ))
    }

    func testAsciiDecimalToCharacter() throws {
        let symbol = try factory.init([
            .decimal(65)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "65.ascii",
            type: .string
        ))
    }
}
