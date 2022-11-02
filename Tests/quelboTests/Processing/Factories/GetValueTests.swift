//
//  GetValueTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GetValueTests: QuelboTests {
    let factory = Factories.GetValue.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("VALUE", type: .zCode))
    }

    func testGetGlobalValue() throws {
        process("<GLOBAL SANDWICH T>")

        let symbol = try factory.init([
            .global(.atom("SANDWICH")),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "sandwich",
            type: .booleanTrue
        ))
    }

    func testGetLocalValue() throws {
        localVariables.append(
            Statement(
                id: "sandwich",
                type: .bool
            )
        )

        let symbol = try factory.init([
            .local("SANDWICH"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "sandwich",
            type: .bool
        ))
    }

    func testStringGetValueToPaperBag() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("SANDWICH"),
                .atom("PAPER-BAG"),
            ], with: &localVariables).process()
        )
    }
}
