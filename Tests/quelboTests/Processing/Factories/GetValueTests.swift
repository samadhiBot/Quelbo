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
        AssertSameFactory(factory, Game.findFactory("VALUE"))
    }

    func testGetGlobalValue() throws {
        try Factories.Global([
            .atom("SANDWICH"),
            .bool(true)
        ], with: &localVariables).process()

        let symbol = try factory.init([
            .global("SANDWICH"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "sandwich",
            type: .booleanTrue
        ))
    }

    func testGetLocalValue() throws {
        localVariables.append(
            Variable(
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
