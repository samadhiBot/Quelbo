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
            Symbol(id: "troll", type: .object, category: .objects)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PTSIZE"))
    }

    func testPropertySize() throws {
        let symbol = try factory.init([
            .global("TROLL"),
            .property("STRENGTH")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "troll.propertySize(of: .strength)",
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
