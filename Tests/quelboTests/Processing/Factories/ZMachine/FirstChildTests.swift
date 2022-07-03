//
//  FirstChildTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class FirstChildTests: QuelboTests {
    let factory = Factories.FirstChild.self

    override func setUp() {
        super.setUp()

        Game.commit([
            Symbol(id: "clearing", type: .object, category: .rooms),
            Symbol(id: "thief", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("FIRST?"))
    }

    func testThiefsFirstInventoryItem() throws {
        let symbol = try factory.init([
            .global("THIEF")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "thief.firstChild",
            type: .object
        ))
    }

    func testFirstItemInClearing() throws {
        let symbol = try factory.init([
            .global("CLEARING")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "clearing.firstChild",
            type: .object
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("thief")
            ], with: &registry)
        )
    }
}
