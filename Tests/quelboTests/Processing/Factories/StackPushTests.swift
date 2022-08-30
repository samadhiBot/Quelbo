//
//  StackPushTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class StackPushTests: QuelboTests {
    let factory = Factories.StackPush.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PUSH"))
    }

    func testStackPushDecimal() throws {
        let symbol = try factory.init([
            .decimal(0)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Stack.push(0)",
            type: .void,
            confidence: .certain
        ))
    }

    func testStackPushMultipleValuesThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ], with: &localVariables).process()
        )
    }
}
