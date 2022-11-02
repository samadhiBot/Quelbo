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

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "west", type: .direction, category: .properties),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ADJECTIVE", type: .property))
    }

    func testAdjectives() throws {
        let symbol = try factory.init([
            .atom("WHITE"),
            .atom("BEAUTI"),
            .atom("COLONI")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "adjectives",
            code: """
                adjectives: [
                    "white",
                    "beauti",
                    "coloni",
                ]
                """,
            type: .string.array
        ))
    }

    func testAdjectivesWithWordThatMatchesDefinedProperty() throws {
        let symbol = try factory.init([
            .atom("WOODEN"),
            .atom("GOTHIC"),
            .atom("STRANGE"),
            .atom("WEST")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "adjectives",
            code: """
                adjectives: [
                    "wooden",
                    "gothic",
                    "strange",
                    "west",
                ]
                """,
            type: .string.array
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "adjectives",
            type: .string.array
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