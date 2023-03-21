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
        let symbol = process("""
            <DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>

            <SYNONYM NW NORTHWEST>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "synonym:nw",
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
            id: "synonym:under",
            code: """
                Syntax.set("under", synonyms: ["below", "beneath", "underneath"])
                """,
            type: .string,
            category: .syntax,
            isCommittable: true
        ))
    }

    func testSynonymSameAsObject() throws {
        let symbol = process("""
            <OBJECT WALL (DESC "surrounding wall")>

            <OBJECT GRANITE-WALL
                (IN GLOBAL-OBJECTS)
                (SYNONYM WALL)
                (ADJECTIVE GRANITE)
                (DESC "granite wall")
                (ACTION GRANITE-WALL-F)>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "graniteWall",
            code: """
                    /// The `graniteWall` (GRANITE-WALL) object.
                    var graniteWall = Object(
                        id: "graniteWall",
                        action: "graniteWallFunc",
                        adjectives: ["granite"],
                        description: "granite wall",
                        location: "globalObjects",
                        synonyms: ["wall"]
                    )
                    """,
            type: .object,
            category: .objects,
            isCommittable: true
        ))
    }
}
