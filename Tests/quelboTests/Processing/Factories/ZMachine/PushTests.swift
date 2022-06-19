//
//  PushTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PushTests: QuelboTests {
    let factory = Factories.Push.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PUSH"))
    }

    func testPushDecimal() throws {
        let symbol = try factory.init([
            .decimal(0)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol("push(0)", type: .void))
    }

    func testPushMultipleValuesThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ]).process()
        )
    }
}
