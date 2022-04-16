//
//  PseudosTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PseudosTests: QuelboTests {
    let factory = Factories.Pseudos.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("PSEUDO"))
    }

    func testPseudos() throws {
        let symbol = try factory.init([
            .string("CHASM"),
            .atom("CHASM-PSEUDO"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "things",
            code: #"""
                things: [
                    Thing(
                        adjectives: [],
                        nouns: ["chasm"],
                        action: chasmPseudo
                    )
                ]
                """#,
            type: .array(.thing),
            children: [
                Symbol(
                    id: "thing",
                    code: #"""
                        Thing(
                            adjectives: [],
                            nouns: ["chasm"],
                            action: chasmPseudo
                        )
                        """#,
                    type: .thing
                )
            ]
        ))
    }

    func testMultiplePseudos() throws {
        let symbol = try factory.init([
            .string("DOOR"),
            .atom("DOOR-PSEUDO"),
            .string("PAINT"),
            .atom("PAINT-PSEUDO"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "things",
            code: #"""
                things: [
                    Thing(
                        adjectives: [],
                        nouns: ["door"],
                        action: doorPseudo
                    ),
                    Thing(
                        adjectives: [],
                        nouns: ["paint"],
                        action: paintPseudo
                    )
                ]
                """#,
            type: .array(.thing),
            children: [
                Symbol(
                    id: "thing",
                    code: #"""
                        Thing(
                            adjectives: [],
                            nouns: ["door"],
                            action: doorPseudo
                        )
                        """#,
                    type: .thing
                ),
                Symbol(
                    id: "thing",
                    code: #"""
                        Thing(
                            adjectives: [],
                            nouns: ["paint"],
                            action: paintPseudo
                        )
                        """#,
                    type: .thing
                ),
            ]
        ))
    }

    func testExtraParamsThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("CHASM"),
                .atom("CHASM-PSEUDO"),
                .string("PAINT"),
            ]).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("CHASM"),
                .atom("CHASM-PSEUDO"),
            ]).process()
        )
    }
}
