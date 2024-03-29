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
            .variable(
                id: "kitchenWindow",
                type: .object,
                category: .objects
            ),
            .variable(
                id: "openBit",
                type: .bool.property,
                category: .flags
            ),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("FSET?"))
    }

    func testHasFlag() throws {
        let symbol = try factory.init([
            .global(.atom("KITCHEN-WINDOW")),
            .global(.atom("OPENBIT")),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "kitchenWindow.hasFlag(.openBit)",
            type: .bool
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("KITCHEN-WINDOW"),
                .global(.atom("OPENBIT")),
            ], with: &localVariables).process()
        )
    }
}
