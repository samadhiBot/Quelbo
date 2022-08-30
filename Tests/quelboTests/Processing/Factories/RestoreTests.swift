//
//  RestoreTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RestoreTests: QuelboTests {
    let factory = Factories.Restore.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("RESTORE"))
    }

    func testRestore() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "restore()",
            type: .void,
            confidence: .certain
        ))
    }

    func testRestoreWithParameterThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ], with: &localVariables).process()
        )
    }
}
