//
//  HasAttributeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class HasAttributeTests: QuelboTests {
    let factory = Factories.HasAttribute.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol("kitchenWindow", type: .object),
            Symbol("openBit", type: .property),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("FSET?"))
    }

    func testHasAttribute() throws {
        let symbol = try factory.init([
            .global("KITCHEN-WINDOW"),
            .global("OPENBIT"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "kitchenWindow.hasAttribute(openBit)",
            type: .bool,
            children: [
                Symbol(
                    id: "kitchenWindow",
                    code: "kitchenWindow",
                    type: .object
                ),
                Symbol(
                    id: "openBit",
                    code: "openBit",
                    type: .bool
                )
            ]
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("KITCHEN-WINDOW"),
                .global("OPENBIT"),
            ]).process()
        )
    }
}
