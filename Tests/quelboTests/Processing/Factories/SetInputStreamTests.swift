//
//  SetInputStreamTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SetInputStreamTests: QuelboTests {
    let factory = Factories.SetInputStream.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("DIRIN"))
    }

    func testSetInputStreamKeyboard() throws {
        let symbol = try factory.init([
            .decimal(0)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "setInputStream(.keyboard)",
            type: .void,
            confidence: .certain
        ))
    }

    func testSetInputStreamFile() throws {
        let symbol = try factory.init([
            .decimal(1)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "setInputStream(.file)",
            type: .void,
            confidence: .certain
        ))
    }

    func testNonIntegerThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("keyboard"),
            ], with: &localVariables).process()
        )
    }

    func testInvalidIntegerThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
            ], with: &localVariables).process()
        )
    }
}
