//
//  PutPropertyTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PutPropertyTests: QuelboTests {
    let factory = Factories.PutProperty.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol(id: "troll", type: .object, category: .objects),
            Symbol(id: "winner", type: .object, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PUTP"))
    }

    func testPutPropertyOnObjectFromObjects() throws {
        let symbol = try factory.init([
            .atom("TROLL"),
            .property("STRENGTH"),
            .decimal(10),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "troll.strength = 10",
            type: .int
        ))
    }

    func testPutPropertyOnObjectFromGlobals() throws {
        let symbol = try factory.init([
            .global("WINNER"),
            .property("ACTION"),
            .decimal(0),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "winner.action = 0",
            type: .int
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("TROLL"),
                .atom("STRENGTH"),
                .decimal(10)
            ]).process()
        )
    }
}
