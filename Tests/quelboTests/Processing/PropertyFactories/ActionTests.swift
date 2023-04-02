//
//  ActionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ActionTests: QuelboTests {
    let factory = Factories.Action.self

    override func setUp() {
        super.setUp()

        process("""
            <ROUTINE WHITE-HOUSE-F ()
                <TELL "The house is a beautiful colonial house..." CR>>

            <OBJECT WHITE-HOUSE
                (ACTION WHITE-HOUSE-F)>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ACTION", type: .property))
    }

    func testObject() throws {
        XCTAssertNoDifference(
            Game.objects.find("whiteHouse"),
            Statement(
                id: "whiteHouse",
                code: """
                /// The `whiteHouse` (WHITE-HOUSE) object.
                var whiteHouse = Object(
                    id: "whiteHouse",
                    action: "whiteHouseFunc"
                )
                """,
                type: .object,
                category: .objects,
                isCommittable: true
            )
        )
    }

    func testAction() throws {
        XCTAssertNoDifference(
            Game.actionRoutines.find("whiteHouseFunc"),
            Statement(
                id: "whiteHouseFunc",
                code: """
                /// The `whiteHouseFunc` (WHITE-HOUSE-F) action routine.
                func whiteHouseFunc() {
                    output("The house is a beautiful colonial house...")
                }
                """,
                type: .routine,
                category: .routines,
                isActionRoutine: true,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "action",
            type: .routine
        ))
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("WHITE-HOUSE-F"),
                .atom("RED-HOUSE-F"),
            ], with: &localVariables).process()
        )
    }
}
