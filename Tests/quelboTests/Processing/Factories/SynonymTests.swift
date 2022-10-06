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
        AssertSameFactory(factory, Game.findFactory("SYNONYM", type: .mdl))
        AssertSameFactory(factory, Game.findFactory("ADJ-SYNONYM", type: .mdl))
        AssertSameFactory(factory, Game.findFactory("DIR-SYNONYM", type: .mdl))
        AssertSameFactory(factory, Game.findFactory("PREP-SYNONYM", type: .mdl))
        AssertSameFactory(factory, Game.findFactory("VERB-SYNONYM", type: .mdl))
    }

    func testSynonym() throws {
        let symbol = process("<SYNONYM NW NORTHWEST>")

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Syntax.set("nw", synonyms: ["northwest"])
                """,
            type: .string,
            category: .syntax,
            isCommittable: true
        ))
    }

    func testMultipleSynonyms() throws {
        let symbol = process("<SYNONYM UNDER UNDERNEATH BENEATH BELOW>")

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Syntax.set("under", synonyms: [
                    "below",
                    "beneath",
                    "underneath",
                ])
                """,
            type: .string,
            category: .syntax,
            isCommittable: true
        ))
    }
}
