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
            Symbol("here", type: .object, category: .rooms),
            Symbol("kitchen", type: .object, category: .rooms),
            Symbol("paperBag", type: .object, category: .objects),
            Symbol("sandwich", type: .object, category: .objects),
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
            type: .void,
            children: [
                Symbol("sandwich", type: .object, category: .objects),
                Symbol("paperBag", type: .object, category: .objects),
            ]
        ))
    }

    func testMovePaperBagToKitchen() throws {
        let symbol = try factory.init([
            .atom("PAPER-BAG"),
            .atom("KITCHEN"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "paperBag.move(to: kitchen)",
            type: .void,
            children: [
                Symbol("paperBag", type: .object, category: .objects),
                Symbol("kitchen", type: .object, category: .rooms),
            ]
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
            type: .void,
            children: [
                Symbol("dweapon", type: .object, meta: [.isLiteral, .maybeEmptyValue]),
                Symbol("here", type: .object, category: .rooms),
            ]
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
