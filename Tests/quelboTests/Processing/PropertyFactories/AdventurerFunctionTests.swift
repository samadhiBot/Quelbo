//
//  AdventurerFunctionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 2/13/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class AdventurerFunctionTests: QuelboTests {
    let factory = Factories.AdventurerFunction.self

    override func setUp() {
        super.setUp()

        process("""
            <ROUTINE BAT-F ()
                <TELL "Fweep!" CR>>

            <OBJECT BAT
                (ADVFCN BAT-F)>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ADVFCN", type: .property))
    }

    func testObject() throws {
        XCTAssertNoDifference(
            Game.objects.find("bat"),
            Statement(
                id: "bat",
                code: """
                    /// The `bat` (BAT) object.
                    var bat = Object(
                        id: "bat",
                        adventurerFunction: "batFunc"
                    )
                    """,
                type: .object,
                category: .objects,
                isCommittable: true
            )
        )
    }

    func testAdventurerFunction() throws {
        XCTAssertNoDifference(
            Game.actionRoutines.find("batFunc"),
            Statement(
                id: "batFunc",
                code: """
                    /// The `batFunc` (BAT-F) action routine.
                    func batFunc() {
                        output("Fweep!")
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
            code: "adventurerFunction",
            type: .routine
        ))
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("WHITE-HOUSE"),
                .atom("RED-HOUSE"),
            ], with: &localVariables).process()
        )
    }
}
