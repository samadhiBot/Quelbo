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
        let symbol = process("""
            <NEXTP TROLL STRENGTH>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: "troll.property(after: strength)",
            type: .unknown.property
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
