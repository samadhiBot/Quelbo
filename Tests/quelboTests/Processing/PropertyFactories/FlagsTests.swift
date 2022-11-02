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
        AssertSameFactory(factory, Game.findFactory("FLAGS", type: .property))
    }

    func testFlags() throws {
        let symbol = process("""
            <OBJECT BROKEN-EGG
                (DESC "broken jewel-encrusted egg")
                (FLAGS TAKEBIT CONTBIT OPENBIT)
                (CAPACITY 6)>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "brokenEgg",
            code: """
                /// The `brokenEgg` (BROKEN-EGG) object.
                var brokenEgg = Object(
                    capacity: 6,
                    description: "broken jewel-encrusted egg",
                    flags: [
                        isContainer,
                        isOpen,
                        isTakable,
                    ]
                )
                """,
            type: .object,
            category: .objects,
            isCommittable: true
        ))

        let flagGlobals: [Symbol] = [
            .statement(
                id: "takeBit",
                code: "isTakable",
                type: .bool,
                category: .flags,
                isCommittable: true
            ),
            .statement(
                id: "contBit",
                code: "isContainer",
                type: .bool,
                category: .flags,
                isCommittable: true
            ),
            .statement(
                id: "openBit",
                code: "isOpen",
                type: .bool,
                category: .flags,
                isCommittable: true
            )
        ]

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
            type: .bool.array
        ))
    }

    func testFlagRegisteredAsGlobal() throws {
        process("<OBJECT BROKEN-EGG (FLAGS TAKEBIT CONTBIT OPENBIT)>")

        let symbol = try Factories.HasFlag([
            .atom("X"),
            .global(.atom("TAKEBIT"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "x.hasFlag(isTakable)",
            type: .bool
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
