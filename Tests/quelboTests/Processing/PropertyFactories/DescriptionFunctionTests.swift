//
//  DescriptionFunctionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DescriptionFunctionTests: QuelboTests {
    let factory = Factories.DescriptionFunction.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findPropertyFactory("DESCFCN"))
    }

    func testDescriptionFunction() throws {
        let symbol = try factory.init([
            .atom("BAT-D")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "descriptionFunction",
            code: "descriptionFunction: batD",
            type: .routine
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "descriptionFunction",
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
