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
        localVariables.append(.init(id: "obj", type: .object))

        let symbol = try factory.init([
            .atom("OBJ")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .instance(.init(
            id: "obj",
            type: .object
        )))
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
            type: .int
        ))
    }

    func testQuoteGlobal() throws {
        let flameBit = Statement(
            id: "flameBit",
            type: .bool,
            category: .globals,
            isCommittable: true
        )

        try Game.commit(.statement(flameBit))

        let symbol = try factory.init([
            .global(.atom("FLAMEBIT"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .instance(flameBit))
    }
}
