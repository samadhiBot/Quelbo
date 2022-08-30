//
//  ClearFlagTests.swift.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ClearFlagTests: QuelboTests {
    let factory = Factories.ClearFlag.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "openBit", type: .bool, category: .globals),
            .variable(id: "trapDoor", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("FCLEAR"))
    }

    func testClearFlag() throws {
        let symbol = try factory.init([
            .global("TRAP-DOOR"),
            .global("OPENBIT"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "trapDoor.openBit.set(false)",
            type: .bool,
            confidence: .certain
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("Trap Door"),
                .global("OPENBIT"),
            ], with: &localVariables).process()
        )
    }

    func testNonBoolFlagThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .global("TRAP-DOOR"),
                .string("11"),
            ], with: &localVariables).process()
        )
    }
}
