//
//  GlobalsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/1/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GlobalsTests: QuelboTests {
    let factory = Factories.Globals.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findPropertyFactory("GLOBAL"))
    }

    func testGlobals() throws {
        let symbol = try factory.init([
            .atom("WELL-HOUSE"),
            .atom("STREAM"),
            .atom("ROAD"),
            .atom("FOREST"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "globals",
            code: """
                globals: [
                    wellHouse,
                    stream,
                    road,
                    forest,
                ]
                """,
            type: .array(.object),
            confidence: .certain
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "globals",
            type: .array(.object),
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
