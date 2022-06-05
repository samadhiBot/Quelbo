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
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("DESCFCN"))
    }

    func testDescriptionFunction() throws {
        let symbol = try factory.init([
            .atom("BAT-D")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "descriptionFunction",
            code: "descriptionFunction: batD",
            type: .routine,
            children: [
                Symbol("batD", type: .routine)
            ]
        ))
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ]).process()
        )
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("WHITE-HOUSE"),
                .atom("RED-HOUSE"),
            ]).process()
        )
    }
}
