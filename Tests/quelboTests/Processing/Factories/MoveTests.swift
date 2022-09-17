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
            .variable(id: "here", type: .object, category: .rooms),
            .variable(id: "kitchen", type: .object, category: .rooms),
            .variable(id: "paperBag", type: .object, category: .objects),
            .variable(id: "sandwich", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("MOVE"))
    }

    func testMoveSandwichToPaperBag() throws {
        let symbol = try factory.init([
            .atom("SANDWICH"),
            .atom("PAPER-BAG"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "sandwich.move(to: paperBag)",
            type: .void
        ))
    }

    func testMovePaperBagToKitchen() throws {
        let symbol = try factory.init([
            .atom("PAPER-BAG"),
            .atom("KITCHEN"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "paperBag.move(to: kitchen)",
            type: .void
        ))
    }

    func testMoveLocalWeaponToHere() throws {
        localVariables.append(
            Variable(id: "dweapon", type: .booleanFalse)
        )

        let symbol = try factory.init([
            .local("DWEAPON"),
            .global("HERE"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "dweapon.move(to: here)",
            type: .void
        ))

        XCTAssertNoDifference(findLocalVariable("dweapon"), Variable(
            id: "dweapon",
            type: .object
        ))
    }

    func testMoveSandwichToDecimal() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("SANDWICH"),
                .decimal(42),
            ], with: &localVariables).process()
        )
    }

    func testMoveStringToPaperBag() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("SANDWICH"),
                .atom("PAPER-BAG"),
            ], with: &localVariables).process()
        )
    }
}
