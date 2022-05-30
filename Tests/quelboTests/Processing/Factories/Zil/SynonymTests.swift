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

    override func setUp() {
        super.setUp()

        try! Game.commit(
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("SYNONYM"))
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("ADJ-SYNONYM"))
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("DIR-SYNONYM"))
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("PREP-SYNONYM"))
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("VERB-SYNONYM"))
    }

    func testSynonym() throws {
        let symbol = try factory.init([
            .atom("NORTH"),
            .atom("FORE")
        ], with: types).process()

        let expected = Symbol(
            id: "<Synonyms:north>",
            code: #"Syntax.set("north", synonyms: "fore")"#,
            type: .string,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("<Synonyms:north>", category: .syntax), expected)
    }

    func testMultipleSynonyms() throws {
        let symbol = try factory.init([
            .atom("PUT"),
            .atom("SLIDE"),
            .atom("DIP"),
            .atom("SOAK"),
        ], with: types).process()

        let expected = Symbol(
            id: "<Synonyms:put>",
            code: #"Syntax.set("put", synonyms: "dip", "slide", "soak")"#,
            type: .string,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("<Synonyms:put>", category: .syntax), expected)
    }
}
