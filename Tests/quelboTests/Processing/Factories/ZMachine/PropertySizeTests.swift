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
            Symbol("troll", type: .object, category: .objects)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PTSIZE"))
    }

    func testPropertySize() throws {
        let symbol = try factory.init([
            .atom("TROLL"),
            .property("STRENGTH")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "troll.propertySize(of: .strength)",
            type: .int,
            children: [
                Symbol("troll", type: .object, category: .objects),
                Symbol("strength", type: .int, category: .properties),
            ]
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
