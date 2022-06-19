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
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("DIRIN"))
    }

    func testSetInputStreamKeyboard() throws {
        let symbol = try factory.init([
            .decimal(0)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "setInputStream(.keyboard)",
            type: .void
        ))
    }

    func testSetInputStreamFile() throws {
        let symbol = try factory.init([
            .decimal(1)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "setInputStream(.file)",
            type: .void
        ))
    }

    func testNonIntegerThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("keyboard"),
            ]).process()
        )
    }

    func testInvalidIntegerThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
            ]).process()
        )
    }
}
