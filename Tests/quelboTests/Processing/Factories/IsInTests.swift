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
            .variable(id: "kitchen", type: .object, category: .rooms),
            .variable(id: "paperBag", type: .object, category: .objects),
            .variable(id: "sandwich", type: .object, category: .objects),
            .variable(id: "vVillain", type: .int, category: .constants),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("IN?"))
    }

    func testSandwichIsInPaperBag() throws {
        let symbol = try factory.init([
            .atom("SANDWICH"),
            .atom("PAPER-BAG"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Object.sandwich.isIn(Object.paperBag)",
            type: .bool
        ))
    }

    func testPaperBagIsInKitchen() throws {
        let symbol = try factory.init([
            .atom("PAPER-BAG"),
            .atom("KITCHEN"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Object.paperBag.isIn(Room.kitchen)",
            type: .bool
        ))
    }

    func testLookupVillainInTableAndSetThenCheckWhetherIsInHere() throws {
        let symbol = process(
            """
                <CONSTANT V-VILLAIN 0>
                <GLOBAL HERE 0>

                <IN? <SET O <GET .OO ,V-VILLAIN>> ,HERE>
            """,
            with: [Statement(id: "oo", type: .table)]
        )

        XCTAssertNoDifference(symbol, .statement(
            code: "o.set(to: try oo.get(at: Constant.vVillain)).isIn(Global.here)",
            type: .bool
        ))
    }

    func testSandwichIsInDecimal() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("SANDWICH"),
                .decimal(42),
            ], with: &localVariables).process()
        )
    }

    func testStringIsInPaperBag() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("SANDWICH"),
                .atom("PAPER-BAG"),
            ], with: &localVariables).process()
        )
    }
}
