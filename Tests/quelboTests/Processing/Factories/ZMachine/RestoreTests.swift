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
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("RESTORE"))
    }

    func testRestore() throws {
        let symbol = try factory.init([]).process()

        XCTAssertNoDifference(symbol, Symbol("restore()", type: .void))
    }

    func testRestoreWithParameterThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ]).process()
        )
    }
}
