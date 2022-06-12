//
//  HasFlagTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class HasFlagTests: QuelboTests {
    let factory = Factories.HasFlag.self

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

    func testHasFlag() throws {
        let symbol = try factory.init([
            .global("KITCHEN-WINDOW"),
            .global("OPENBIT"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "kitchenWindow.hasFlag(openBit)",
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
