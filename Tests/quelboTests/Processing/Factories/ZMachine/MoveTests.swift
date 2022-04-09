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
            Symbol("sandwich", type: .object, category: .objects),
            Symbol("paperBag", type: .object, category: .objects),
            Symbol("kitchen", type: .object, category: .rooms),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("MOVE"))
    }

    func testSandwichMoveToPaperBag() throws {
        let symbol = try factory.init([
            .atom("SANDWICH"),
            .atom("PAPER-BAG"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "sandwich.move(to: paperBag)",
            type: .void,
            children: [
                Symbol("sandwich", type: .object, category: .objects),
                Symbol("paperBag", type: .object, category: .objects),
            ]
        ))
    }

    func testPaperBagMoveToKitchen() throws {
        let symbol = try factory.init([
            .atom("PAPER-BAG"),
            .atom("KITCHEN"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "paperBag.move(to: kitchen)",
            type: .void,
            children: [
                Symbol("paperBag", type: .object, category: .objects),
                Symbol("kitchen", type: .object, category: .rooms),
            ]
        ))
    }

    func testSandwichMoveToDecimal() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("SANDWICH"),
                .decimal(42),
            ]).process()
        )
    }

    func testStringMoveToPaperBag() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("SANDWICH"),
                .atom("PAPER-BAG"),
            ]).process()
        )
    }
}
