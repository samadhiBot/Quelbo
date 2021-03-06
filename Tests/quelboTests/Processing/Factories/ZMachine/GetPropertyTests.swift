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
            Symbol(id: "troll", type: .object, category: .objects)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("GETP"))
    }

    func testGetProperty() throws {
        let symbol = try factory.init([
            .atom("TROLL"),
            .property("STRENGTH")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "troll.strength",
            type: .int
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("TROLL"),
                .global("P?STRENGTH")
            ]).process()
        )
    }
}
