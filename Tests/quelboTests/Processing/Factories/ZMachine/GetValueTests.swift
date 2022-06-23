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
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("VALUE"))
    }

    func testGetGlobalValue() throws {
        _ = try Factories.Global([
            .atom("SANDWICH"),
            .bool(true)
        ]).process()

        let symbol = try factory.init([
            .global("SANDWICH"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "sandwich",
            code: "sandwich",
            type: .bool,
            category: .globals
        ))
    }

    func testGetLocalValue() throws {
        let registry = SymbolRegistry([
            Symbol(
                id: "sandwich",
                code: "var sandwich: Bool = true",
                type: .bool,
                category: .globals
            )
        ])

        let symbol = try factory.init([
            .local("SANDWICH"),
        ], with: registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "sandwich",
            code: "sandwich",
            type: .bool,
            category: .globals
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
