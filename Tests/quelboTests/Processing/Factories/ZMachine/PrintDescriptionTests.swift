//
//  PrintDescriptionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PrintDescriptionTests: QuelboTests {
    let factory = Factories.PrintDescription.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol(id: "troll", type: .object, category: .objects)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PRINTD"))
    }

    func testPrintDescription() throws {
        let symbol = try factory.init([
            .global("TROLL")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "output(troll.description)",
            type: .void
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("wat?")
            ]).process()
        )
    }
}
