//
//  PrintTableTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PrintTableTests: QuelboTests {
    let factory = Factories.PrintTable.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PRINTF"))
    }

    func testPrintTable() throws {
        let symbol = try factory.init([
            .atom("FOO")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "output(foo)",
            type: .void
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ], with: &localVariables).process()
        )
    }
}
