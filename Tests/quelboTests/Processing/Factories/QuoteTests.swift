//
//  QuoteTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/4/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class QuoteTests: QuelboTests {
    let factory = Factories.Quote.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("QUOTE"))
    }

    func testQuoteAtom() throws {
        let symbol = try factory.init([
            .atom("OBJ")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .variable(id: "obj"))
    }

    func testQuoteForm() throws {
        let symbol = try factory.init([
            .form([
                .atom("RANDOM"),
                .decimal(100)
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".random(100)",
            type: .int,
            confidence: .certain
        ))
    }

    func testQuoteGlobal() throws {
        let flameBit: Symbol = .variable(
            id: "flameBit",
            type: .bool,
            category: .globals,
            confidence: .certain,
            isMutable: true
        )

        try Game.commit(flameBit)

        let symbol = try factory.init([
            .global("FLAMEBIT")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, flameBit)
    }
}
