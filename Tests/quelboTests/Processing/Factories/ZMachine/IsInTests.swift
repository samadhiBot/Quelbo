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

        let _ = try! Factories.Global([.atom("HERE"), .decimal(0)], with: &registry).process()

        Game.commit([
            Symbol(id: "kitchen", type: .object, category: .rooms),
            Symbol(id: "paperBag", type: .object, category: .objects),
            Symbol(id: "sandwich", type: .object, category: .objects),
            Symbol(id: "vVillain", type: .int, category: .constants),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("IN?"))
    }

    func testSandwichIsInPaperBag() throws {
        let symbol = try factory.init([
            .atom("SANDWICH"),
            .atom("PAPER-BAG"),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "sandwich.isIn(paperBag)",
            type: .bool
        ))
    }

    func testPaperBagIsInKitchen() throws {
        let symbol = try factory.init([
            .atom("PAPER-BAG"),
            .atom("KITCHEN"),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "paperBag.isIn(kitchen)",
            type: .bool
        ))
    }

    func testLookupVillainInTableAndSetThenCheckWhetherIsInHere() throws {
        registry.insert(
            Symbol(id: "oo", type: .variable(.table))
        )

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
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "o.set(to: try oo.get(at: vVillain)).isIn(here)",
            type: .bool
        ))
    }

    func testSandwichIsInDecimal() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("SANDWICH"),
                .decimal(42),
            ], with: &registry).process()
        )
    }

    func testStringIsInPaperBag() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("SANDWICH"),
                .atom("PAPER-BAG"),
            ], with: &registry).process()
        )
    }
}
