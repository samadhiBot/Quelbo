//
//  SynonymsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SynonymsTests: QuelboTests {
    let factory = Factories.Synonyms.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("SYNONYM"))
    }

    func testSynonyms() throws {
        let symbol = try factory.init([
            .atom("EGG"),
            .atom("TREASURE")
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "synonyms",
            code: """
                synonyms: ["egg", "treasure"]
                """,
            type: .array(.string),
            children: [
                Symbol("egg", type: .string, meta: [.isLiteral]),
                Symbol("treasure", type: .string, meta: [.isLiteral]),
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
