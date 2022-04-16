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
            Symbol("troll", type: .object, category: .objects)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PUTP"))
    }

    func testPutProperty() throws {
        let symbol = try factory.init([
            .atom("TROLL"),
            .atom(",P?STRENGTH"),
            .decimal(10)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "troll.strength = 10",
            type: .int,
            children: [
                Symbol("troll", type: .object, category: .objects),
                Symbol("strength", type: .int, category: .properties),
                Symbol("10", type: .int),
            ]
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

    func testNonPropertyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("TROLL"),
                .string("STRENGTH"),
                .decimal(10)
            ]).process()
        )
    }
}
