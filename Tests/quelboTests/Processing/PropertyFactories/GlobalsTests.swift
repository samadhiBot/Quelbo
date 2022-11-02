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
        AssertSameFactory(factory, Game.findFactory("GLOBAL", type: .property))
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
            type: .object.array
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "globals",
            type: .object.array
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
