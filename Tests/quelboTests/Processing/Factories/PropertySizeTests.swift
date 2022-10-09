//
//  PropertySizeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PropertySizeTests: QuelboTests {
    let factory = Factories.PropertySize.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "troll", type: .object, category: .objects)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PTSIZE"))
    }

    func testPropertySize() throws {
        let symbol = try factory.init([
            .global(.atom("TROLL")),
            .property("STRENGTH")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "troll.propertySize(of: .strength)",
            type: .int
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("TROLL"),
                .global(.atom("P?STRENGTH"))
            ], with: &localVariables).process()
        )
    }
}
