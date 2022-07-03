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

        Game.commit([
            Symbol(id: "sandwich", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("REMOVE"))
    }

    func testRemoveSandwich() throws {
        let symbol = try factory.init([
            .global("SANDWICH"),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "sandwich.remove()",
            type: .void
        ))
    }

    func testRemoveNonObject() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ], with: &registry).process()
        )
    }

    func testStringRemoveToPaperBag() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("SANDWICH"),
                .atom("PAPER-BAG"),
            ], with: &registry).process()
        )
    }
}
