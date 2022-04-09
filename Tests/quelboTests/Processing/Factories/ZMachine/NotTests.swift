//
//  NotTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class NotTests: QuelboTests {
    let factory = Factories.Not.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("NOT"))
    }

    func testNot() throws {
        let symbol = try factory.init([
            .bool(true)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "!true",
            type: .bool,
            children: [
                Symbol("true", type: .bool)
            ]
        ))
    }

    func testNotNonBooleanThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("wat?")
            ]).process()
        )
    }
}
