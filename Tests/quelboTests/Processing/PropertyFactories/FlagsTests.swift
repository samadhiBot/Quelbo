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
        AssertSameFactory(factory, Game.findPropertyFactory("FLAGS"))
    }

    func testFlags() throws {
        let symbol = try factory.init([
            .atom("TAKEBIT"),
            .atom("CONTBIT"),
            .atom("OPENBIT")
        ], with: &localVariables).process()

        let flagGlobals: [Symbol] = [
            .statement(
                id: "takeBit",
                code: "isTakable",
                type: .bool,
                confidence: .certain,
                category: .flags
            ),
            .statement(
                id: "contBit",
                code: "isContainer",
                type: .bool,
                confidence: .certain,
                category: .flags
            ),
            .statement(
                id: "openBit",
                code: "isOpen",
                type: .bool,
                confidence: .certain,
                category: .flags
            )
        ]

        XCTAssertNoDifference(symbol, .statement(
            id: "flags",
            code: """
                flags: [
                    isContainer,
                    isOpen,
                    isTakable,
                ]
                """,
            type: .array(.bool),
            confidence: .certain
        ))

        flagGlobals.forEach { flag in
            guard
                let flagID = flag.id,
                let global = Game.flags.find(flagID)
            else {
                return XCTFail("No flag found with id \(String(describing: flag.id))")
            }
            XCTAssertEqual(flag, .statement(global))
        }
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "flags",
            type: .array(.bool),
            confidence: .certain
        ))
    }

    func testFlagRegisteredAsGlobal() throws {
        _ = try factory.init([
            .atom("TAKEBIT"),
        ], with: &localVariables).process()

        let symbol = try Factories.HasFlag([
            .atom("X"),
            .global("TAKEBIT")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "x.hasFlag(isTakable)",
            type: .bool,
            confidence: .certain
        ))
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("42"),
            ], with: &localVariables).process()
        )
    }
}
