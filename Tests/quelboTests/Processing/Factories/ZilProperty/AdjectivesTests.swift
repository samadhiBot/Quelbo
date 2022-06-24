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
            Symbol(id: "west", type: .direction, category: .properties),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("ADJECTIVE"))
    }

    func testAdjectives() throws {
        let symbol = try factory.init([
            .atom("WHITE"),
            .atom("BEAUTI"),
            .atom("COLONI")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "adjectives",
            code: """
                adjectives: [
                    "white",
                    "beauti",
                    "coloni",
                ]
                """,
            type: .array(.string)
        ))
    }

    func testAdjectivesWithWordThatMatchesDefinedProperty() throws {
        let symbol = try factory.init([
            .atom("WOODEN"),
            .atom("GOTHIC"),
            .atom("STRANGE"),
            .atom("WEST")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "adjectives",
            code: """
                adjectives: [
                    "wooden",
                    "gothic",
                    "strange",
                    "west",
                ]
                """,
            type: .array(.string)
        ))
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ]).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ]).process()
        )
    }
}
