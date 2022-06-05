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
            "sandwich.move(to: paperBag)",
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
            "paperBag.move(to: kitchen)",
            type: .void,
            children: [
                Symbol("paperBag", type: .object, category: .objects),
                Symbol("kitchen", type: .object, category: .rooms),
            ]
        ))
    }

    func testParsedDirectObjectToKitchen() throws {
        _ = try Factories.Global([
            .atom("PRSO"),
            .bool(false)
        ]).process()

        let symbol = try factory.init([
            .global("PRSO"),
            .global("KITCHEN")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "prso.move(to: kitchen)",
            type: .void,
            children: [
                Symbol("prso", type: .object, category: .globals),
                Symbol("kitchen", type: .object, category: .rooms),
            ]
        ))

        XCTAssertNoDifference(try Game.find("prso"), Symbol(
            id: "prso",
            code: "var prso: Object = .nullObject",
            type: .object,
            category: .globals
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
