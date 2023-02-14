//
//  AdventurerFunctionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 2/13/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class AdventurerFunctionTests: QuelboTests {
    let factory = Factories.AdventurerFunction.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ADVFCN", type: .property))
    }

    func testAdventurerFunction() throws {
        let symbol = try factory.init([
            .atom("BAT-D")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "adventurerFunction",
            code: "adventurerFunction: batD",
            type: .routine
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "adventurerFunction",
            type: .routine
        ))
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("WHITE-HOUSE"),
                .atom("RED-HOUSE"),
            ], with: &localVariables).process()
        )
    }
}
