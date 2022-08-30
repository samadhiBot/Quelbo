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
        AssertSameFactory(factory, Game.findPropertyFactory("SYNONYM"))
    }

    func testSynonyms() throws {
        let symbol = try factory.init([
            .atom("EGG"),
            .atom("TREASURE")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "synonyms",
            code: """
                synonyms: ["egg", "treasure"]
                """,
            type: .array(.string),
            confidence: .certain
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "synonyms",
            type: .array(.string),
            confidence: .certain
        ))
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ], with: &localVariables).process()
        )
    }
}
