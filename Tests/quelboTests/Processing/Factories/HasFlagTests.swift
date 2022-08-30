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
            .variable(id: "kitchenWindow", type: .object),
            .variable(id: "openBit", type: .property(.bool)),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("FSET?"))
    }

    func testHasFlag() throws {
        let symbol = try factory.init([
            .global("KITCHEN-WINDOW"),
            .global("OPENBIT"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "kitchenWindow.hasFlag(openBit)",
            type: .bool,
            confidence: .certain
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("KITCHEN-WINDOW"),
                .global("OPENBIT"),
            ], with: &localVariables).process()
        )
    }
}
