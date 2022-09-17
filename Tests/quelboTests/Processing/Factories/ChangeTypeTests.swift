//
//  ChangeTypeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/2/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ChangeTypeTests: QuelboTests {
    let factory = Factories.ChangeType.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("CHTYPE"))
    }

    func testChangeTypeCharacterToDecimal() throws {
        let symbol = try factory.init([
            .character("A"),
            .atom("FIX"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                "A".changeType(.fix)
                """,
            type: .int
        ))
    }

    func testChangeTypeDecimalToCharacter() throws {
        let symbol = try factory.init([
            .decimal(65),
            .atom("STRING"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "65.changeType(.string)",
            type: .string
        ))
    }
}
