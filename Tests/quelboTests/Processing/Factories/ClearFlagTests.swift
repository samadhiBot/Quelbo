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

        process("<OBJECT TRAP-DOOR (FLAGS OPENBIT)>")
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("FCLEAR"))
    }

    func testClearFlag() throws {
        let symbol = try factory.init([
            .global(.atom("TRAP-DOOR")),
            .global(.atom("OPENBIT")),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Objects.trapDoor.isOpen.set(false)",
            type: .bool
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("Trap Door"),
                .global(.atom("OPENBIT")),
            ], with: &localVariables).process()
        )
    }

    func testNonBoolFlagThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .global(.atom("TRAP-DOOR")),
                .string("11"),
            ], with: &localVariables).process()
        )
    }
}
