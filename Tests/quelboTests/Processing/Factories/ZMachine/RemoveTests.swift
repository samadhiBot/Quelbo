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
            Symbol("sandwich", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("REMOVE"))
    }

    func testRemoveSandwich() throws {
        let symbol = try factory.init([
            .atom("SANDWICH"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "sandwich.remove()",
            type: .void,
            children: [
                Symbol("sandwich", type: .object, category: .objects),
            ]
        ))
    }

    func testRemoveNonObject() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ]).process()
        )
    }

    func testStringRemoveToPaperBag() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("SANDWICH"),
                .atom("PAPER-BAG"),
            ]).process()
        )
    }
}
