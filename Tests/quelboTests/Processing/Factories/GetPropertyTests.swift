//
//  GetPropertyTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GetPropertyTests: QuelboTests {
    let factory = Factories.GetProperty.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "count", type: .int),
            .variable(id: "troll", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("GETP"))
    }

    func testGetProperty() throws {
        let symbol = try factory.init([
            .atom("TROLL"),
            .property("STRENGTH")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "troll.strength",
            type: .int.property
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("COUNT"),
                .property("STRENGTH")
            ], with: &localVariables).process()
        )
    }
}
