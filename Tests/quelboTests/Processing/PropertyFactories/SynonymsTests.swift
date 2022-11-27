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
        AssertSameFactory(factory, Game.findFactory("SYNONYM", type: .property))
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
            type: .string.array
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "synonyms",
            type: .string.array
        ))
    }
}
