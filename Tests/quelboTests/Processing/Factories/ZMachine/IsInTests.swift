//
//  IsInTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsInTests: QuelboTests {
    let factory = Factories.IsIn.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol(
                "here",
                type: .object,
                category: .globals,
                meta: [.maybeEmptyValue, .mutating(true)]
            ),
            Symbol("kitchen", type: .object, category: .rooms),
            Symbol("paperBag", type: .object, category: .objects),
            Symbol("sandwich", type: .object, category: .objects),
            Symbol("vVillain", type: .int, category: .constants),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("IN?"))
    }

    func testSandwichIsInPaperBag() throws {
        let symbol = try factory.init([
            .atom("SANDWICH"),
            .atom("PAPER-BAG"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "sandwich.isIn(paperBag)",
            type: .bool,
            children: [
                Symbol("sandwich", type: .object, category: .objects),
                Symbol("paperBag", type: .object, category: .objects),
            ]
        ))
    }

    func testPaperBagIsInKitchen() throws {
        let symbol = try factory.init([
            .atom("PAPER-BAG"),
            .atom("KITCHEN"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "paperBag.isIn(kitchen)",
            type: .bool,
            children: [
                Symbol("paperBag", type: .object, category: .objects),
                Symbol("kitchen", type: .object, category: .rooms),
            ]
        ))
    }

    func testLookupVillainInTableAndSetThenCheckWhetherIsInHere() throws {
        let symbol = try factory.init([
            .form([
                .atom("SET"),
                .atom("O"),
                .form([
                    .atom("GET"),
                    .local("OO"),
                    .global("V-VILLAIN")
                ])
            ]),
            .global("HERE")
        ]).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            "o.set(to: try oo.get(at: vVillain)).isIn(here)",
            type: .bool
        ))
    }

    func testSandwichIsInDecimal() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("SANDWICH"),
                .decimal(42),
            ]).process()
        )
    }

    func testStringIsInPaperBag() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("SANDWICH"),
                .atom("PAPER-BAG"),
            ]).process()
        )
    }
}
