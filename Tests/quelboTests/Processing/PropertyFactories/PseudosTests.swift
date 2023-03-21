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
        AssertSameFactory(factory, Game.findFactory("PSEUDO", type: .property))
    }

    func testPseudos() throws {
        let symbol = try factory.init([
            .string("CHASM"),
            .atom("CHASM-PSEUDO"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "things",
            code: #"""
                things: [
                    Thing(
                        action: "chasmPseudo",
                        adjectives: [],
                        nouns: ["chasm"]
                    ),
                ]
                """#,
            type: .object.array
        ))
    }

    func testMultiplePseudos() throws {
        let symbol = try factory.init([
            .string("DOOR"),
            .atom("DOOR-PSEUDO"),
            .string("PAINT"),
            .atom("PAINT-PSEUDO"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "things",
            code: """
                things: [
                    Thing(
                        action: "doorPseudo",
                        adjectives: [],
                        nouns: ["door"]
                    ),
                    Thing(
                        action: "paintPseudo",
                        adjectives: [],
                        nouns: ["paint"]
                    ),
                ]
                """,
            type: .object.array
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "things",
            type: .object.array
        ))
    }

    func testExtraParamsThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("CHASM"),
                .atom("CHASM-PSEUDO"),
                .string("PAINT"),
            ], with: &localVariables).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("CHASM"),
                .atom("CHASM-PSEUDO"),
            ], with: &localVariables).process()
        )
    }
}
