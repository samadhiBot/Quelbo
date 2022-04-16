//
//  FlagsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class FlagsTests: QuelboTests {
    let factory = Factories.Flags.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("FLAGS"))
    }

    func testFlags() throws {
        let symbol = try factory.init([
            .atom("TAKEBIT"),
            .atom("CONTBIT"),
            .atom("OPENBIT")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "flags",
            code: """
                flags: [
                    takeBit,
                    contBit,
                    openBit
                ]
                """,
            type: .array(.bool),
            children: [
                Symbol("takeBit", type: .bool),
                Symbol("contBit", type: .bool),
                Symbol("openBit", type: .bool),
            ]
        ))
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ]).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("42"),
            ]).process()
        )
    }
}
