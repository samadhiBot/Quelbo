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

        try! Game.commit([
            .variable(id: "here", type: .object, category: .rooms),
            .variable(id: "troll", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("GETPT"))
    }

    func testPropertyIndexOfObjectInObjects() throws {
        let symbol = try factory.init([
            .atom("TROLL"),
            .property("STRENGTH")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "troll.propertyIndex(of: .strength)",
            type: .int
        ))
    }

    func testPropertyIndexOfObjectInLocal() throws {
        localVariables.append(
            Statement(id: "dir", type: .direction)
        )

        let symbol = try factory.init([
            .global(.atom("HERE")),
            .local("DIR")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "here.propertyIndex(of: .dir)",
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
