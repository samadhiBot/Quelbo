//
//  RemoveTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RemoveTests: QuelboTests {
    let factory = Factories.Remove.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "sandwich", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("REMOVE"))
    }

    func testRemoveSandwich() throws {
        let symbol = try factory.init([
            .global(.atom("SANDWICH")),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "sandwich.remove()",
            type: .void
        ))
    }

    func testRemoveNonObject() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ], with: &localVariables).process()
        )
    }

    func testStringRemoveToPaperBag() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("SANDWICH"),
                .atom("PAPER-BAG"),
            ], with: &localVariables).process()
        )
    }
}
