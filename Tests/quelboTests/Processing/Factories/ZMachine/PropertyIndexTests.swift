//
//  PropertyIndexTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PropertyIndexTests: QuelboTests {
    let factory = Factories.PropertyIndex.self

    override func setUp() {
        super.setUp()

        Game.commit([
            Symbol(id: "here", type: .object, category: .rooms),
            Symbol(id: "troll", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("GETPT"))
    }

    func testPropertyIndexOfObjectInObjects() throws {
        let symbol = try factory.init([
            .atom("TROLL"),
            .property("STRENGTH")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "troll.propertyIndex(of: .strength)",
            type: .int
        ))
    }

    func testPropertyIndexOfObjectInLocal() throws {
        registry.insert(
            Symbol(id: "dir", type: .direction)
        )

        let symbol = try factory.init([
            .global("HERE"),
            .local("DIR")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "here.propertyIndex(of: .dir)",
            type: .int
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("TROLL"),
                .global("P?STRENGTH")
            ], with: &registry).process()
        )
    }
}
