//
//  MoveTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class MoveTests: QuelboTests {
    let factory = Factories.Move.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol(id: "here", type: .object, category: .rooms),
            Symbol(id: "kitchen", type: .object, category: .rooms),
            Symbol(id: "paperBag", type: .object, category: .objects),
            Symbol(id: "sandwich", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("MOVE"))
    }

    func testMoveSandwichToPaperBag() throws {
        let symbol = try factory.init([
            .atom("SANDWICH"),
            .atom("PAPER-BAG"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "sandwich.move(to: paperBag)",
            type: .void
        ))
    }

    func testMovePaperBagToKitchen() throws {
        let symbol = try factory.init([
            .atom("PAPER-BAG"),
            .atom("KITCHEN"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "paperBag.move(to: kitchen)",
            type: .void
        ))
    }

    func testMoveLocalWeaponToHere() throws {
        let registry = SymbolRegistry([
            Symbol("dweapon", type: .bool, meta: [.isLiteral, .maybeEmptyValue]),
        ])

        let symbol = try factory.init([
            .local("DWEAPON"),
            .global("HERE"),
        ], with: registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            "dweapon.move(to: here)",
            type: .void
        ))
    }

    func testMoveSandwichToDecimal() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("SANDWICH"),
                .decimal(42),
            ]).process()
        )
    }

    func testMoveStringToPaperBag() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("SANDWICH"),
                .atom("PAPER-BAG"),
            ]).process()
        )
    }
}
