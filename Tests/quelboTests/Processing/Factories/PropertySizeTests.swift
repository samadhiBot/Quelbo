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
        localVariables.append(.init(id: "tx", type: .unknown))

        let symbol = process("<PTSIZE .TX>")

        XCTAssertNoDifference(symbol, .statement(
            code: "tx.propertySize",
            type: .int
        ))

        XCTAssertNoDifference(
            findLocalVariable("tx"),
            .init(
                id: "tx",
                type: .unknown.property
            )
        )
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
