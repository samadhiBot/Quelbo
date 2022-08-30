//
//  SynonymTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/4/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SynonymTestsTests: QuelboTests {
    let factory = Factories.Synonym.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("SYNONYM", root: true))
        AssertSameFactory(factory, Game.findFactory("ADJ-SYNONYM", root: true))
        AssertSameFactory(factory, Game.findFactory("DIR-SYNONYM", root: true))
        AssertSameFactory(factory, Game.findFactory("PREP-SYNONYM", root: true))
        AssertSameFactory(factory, Game.findFactory("VERB-SYNONYM", root: true))
    }

    func testSynonym() throws {
        let symbol = try factory.init([
            .atom("NORTH"),
            .atom("FORE")
        ], with: &localVariables).process()

        let expected = Statement(
            id: "synonyms:north",
            code: #"Syntax.set("north", synonyms: "fore")"#,
            type: .string,
            confidence: .certain,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.syntax.find("synonyms:north"), expected)
    }

    func testMultipleSynonyms() throws {
        let symbol = try factory.init([
            .atom("PUT"),
            .atom("SLIDE"),
            .atom("DIP"),
            .atom("SOAK"),
        ], with: &localVariables).process()

        let expected = Statement(
            id: "synonyms:put",
            code: #"Syntax.set("put", synonyms: "dip", "slide", "soak")"#,
            type: .string,
            confidence: .certain,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.syntax.find("synonyms:put"), expected)
    }
}
