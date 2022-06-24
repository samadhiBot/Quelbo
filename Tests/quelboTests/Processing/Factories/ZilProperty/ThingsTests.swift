//
//  ThingsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ThingsTests: QuelboTests {
    let factory = Factories.Things.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("THINGS"))
    }

    func testThings() throws {
        let symbol = try factory.init([
            .list([
                .atom("FLOWERY"),
                .atom("SCRAWLED")
            ]),
            .list([
                .atom("MESSAGE"),
                .atom("SCRAWL"),
                .atom("WRITING"),
                .atom("SCRIPT")
            ]),
            .string("""
                The message reads, "This is not the maze where the pirate \
                leaves his treasure chest."
                """)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "things",
            code: #"""
                things: [
                    Thing(
                        adjectives: ["flowery", "scrawled"],
                        nouns: ["message", "scrawl", "writing", "script"],
                        text: """
                            The message reads, "This is not the maze where the pirate \
                            leaves his treasure chest."
                            """
                    ),
                ]
                """#,
            type: .array(.thing)
        ))
    }

    func testThingsNoAdjectives() throws {
        let symbol = try factory.init([
            .bool(false),
            .list([
                .atom("WRITING"),
                .atom("SCRIPT")
            ]),
            .string("The message reads...")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "things",
            code: #"""
                things: [
                    Thing(
                        adjectives: [],
                        nouns: ["writing", "script"],
                        text: "The message reads..."
                    ),
                ]
                """#,
            type: .array(.thing)
        ))
    }

    func testThingsActionFunction() throws {
        let symbol = try factory.init([
            .list([
                .atom("FLOWERY"),
                .atom("SCRAWLED")
            ]),
            .list([
                .atom("WRITING"),
                .atom("SCRIPT")
            ]),
            .atom("PIT-CRACK-F")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "things",
            code: #"""
                things: [
                    Thing(
                        adjectives: ["flowery", "scrawled"],
                        nouns: ["writing", "script"],
                        action: pitCrackFunc
                    ),
                ]
                """#,
            type: .array(.thing)
        ))
    }

    func testThingsAtomArgs() throws {
        let symbol = try factory.init([
            .atom("FLOWERY"),
            .atom("MESSAGE"),
            .string("The message reads...")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "things",
            code: #"""
                things: [
                    Thing(
                        adjectives: ["flowery"],
                        nouns: ["message"],
                        text: "The message reads..."
                    ),
                ]
                """#,
            type: .array(.thing)
        ))
    }

    func testNonThreeParamsThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .list([
                    .atom("FLOWERY"),
                    .atom("SCRAWLED")
                ]),
            ]).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("42"),
                .string("43"),
                .string("44"),
            ]).process()
        )
    }
}
