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

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol("sandwich", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("VALUE"))
    }

    func testGetValueSandwich() throws {
        let symbol = try factory.init([
            .atom("SANDWICH"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "sandwich",
            type: .object,
            category: .objects
        ))
    }

    func testGetValueNonObject() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ]).process()
        )
    }

    func testStringGetValueToPaperBag() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("SANDWICH"),
                .atom("PAPER-BAG"),
            ]).process()
        )
    }
}
