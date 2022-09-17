//
//  PropertyNextTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PropertyNextTests: QuelboTests {
    let factory = Factories.PropertyNext.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "troll", type: .object, category: .objects)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("NEXTP"))
    }

    func testPropertyNext() throws {
        let symbol = try factory.init([
            .atom("TROLL"),
            .property("STRENGTH")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "troll.nextProperty(after: .strength)",
            type: .int
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("TROLL"),
                .global("P?STRENGTH")
            ], with: &localVariables).process()
        )
    }
}
