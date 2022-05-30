//
//  AdjectivesTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class AdjectivesTests: QuelboTests {
    let factory = Factories.Adjectives.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("ADJECTIVE"))
    }

    func testAdjectives() throws {
        let symbol = try factory.init([
            .atom("WHITE"),
            .atom("BEAUTI"),
            .atom("COLONI")
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "adjectives",
            code: """
                adjectives: [
                    "white",
                    "beauti",
                    "coloni",
                ]
                """,
            type: .array(.string),
            children: [
                Symbol("white", type: .string, meta: [.isLiteral]),
                Symbol("beauti", type: .string, meta: [.isLiteral]),
                Symbol("coloni", type: .string, meta: [.isLiteral]),
            ]
        ))
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
                .decimal(42),
            ], with: types).process()
        )
    }
}
