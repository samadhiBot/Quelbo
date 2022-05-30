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
        ], with: types).process()

        let flagGlobals = [
            Symbol(
                id: "takeBit",
                code: "isTakable",
                type: .bool,
                category: .flags
            ),
            Symbol(
                id: "contBit",
                code: "isContainer",
                type: .bool,
                category: .flags
            ),
            Symbol(
                id: "openBit",
                code: "isOpen",
                type: .bool,
                category: .flags
            )
        ]

        XCTAssertNoDifference(symbol, Symbol(
            id: "flags",
            code: """
                flags: [
                    isContainer,
                    isOpen,
                    isTakable,
                ]
                """,
            type: .array(.bool),
            children: flagGlobals
        ))

        try flagGlobals.forEach { flag in
            let global = try Game.find(flag.id, category: .flags)
            XCTAssertEqual(flag, global)
        }
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ], with: types).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("42"),
            ], with: types).process()
        )
    }
}
