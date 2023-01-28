//
//  AdjectivesTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class AdjectivesTests: QuelboTests {
    let factory = Factories.Adjectives.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "west", type: .object, category: .properties),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ADJECTIVE", type: .property))
    }

    func testAdjectives() throws {
        let symbol = process("""
            <OBJECT WHITE-HOUSE (ADJECTIVE WHITE BEAUTI COLONI)>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "whiteHouse",
            code: """
                /// The `whiteHouse` (WHITE-HOUSE) object.
                var whiteHouse = Object(
                    id: "whiteHouse",
                    adjectives: [
                        "white",
                        "beauti",
                        "coloni",
                    ]
                )
                """,
            type: .object,
            category: .objects,
            isCommittable: true
        ))
    }

    func testAdjectivesWithWordThatMatchesDefinedProperty() throws {
        let symbol = process("""
            <DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>

            <OBJECT WOODEN-DOOR (ADJECTIVE WOODEN GOTHIC STRANGE WEST)>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "woodenDoor",
            code: """
                /// The `woodenDoor` (WOODEN-DOOR) object.
                var woodenDoor = Object(
                    id: "woodenDoor",
                    adjectives: [
                        "wooden",
                        "gothic",
                        "strange",
                        "west",
                    ]
                )
                """,
            type: .object,
            category: .objects,
            isCommittable: true
        ))
    }

    func testAdjectivesWithComment() throws {
        let symbol = process("""
            <OBJECT TREE (ADJECTIVE LARGE STORM ;"-TOSSED")>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "tree",
            code: """
                /// The `tree` (TREE) object.
                var tree = Object(
                    id: "tree",
                    adjectives: ["large", "storm"]
                )
                """,
            type: .object,
            category: .objects,
            isCommittable: true
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "adjectives",
            type: .string.array
        ))
    }
}
