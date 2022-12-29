//
//  SyntaxTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/5/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SyntaxTests: QuelboTests {
    let factory = Factories.Syntax.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("SYNTAX"))
    }

    func testQuitSyntax() throws {
        let symbol = process("<SYNTAX QUIT = V-QUIT>")

        XCTAssertNoDifference(symbol, .statement(
            id: "syntax:quit",
            code: """
                Syntax(
                    verb: "quit",
                    actionRoutine: vQuit
                )
                """,
            type: .void,
            category: .syntax,
            isCommittable: true
        ))
    }

    func testContemplateSyntax() throws {
        let symbol = process("<SYNTAX CONTEMPLATE OBJECT = V-THINK-ABOUT>")

        XCTAssertNoDifference(symbol, .statement(
            id: "syntax:contemplate-object",
            code: """
                Syntax(
                    verb: "contemplate",
                    directObject: Syntax.Object(),
                    actionRoutine: vThinkAbout
                )
                """,
            type: .void,
            category: .syntax,
            isCommittable: true
        ))
    }

    func testTakeSyntax() throws {
        let symbol = process("""
            <SYNTAX TAKE OBJECT (FIND TAKEBIT) (MANY ON-GROUND IN-ROOM) = V-TAKE>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "syntax:take-object",
            code: """
                Syntax(
                    verb: "take",
                    directObject: Syntax.Object(
                        where: isTakable,
                        search: [.inRoom, .many, .onGround]
                    ),
                    actionRoutine: vTake
                )
                """,
            type: .void,
            category: .syntax,
            isCommittable: true
        ))
    }

    func testTakeOffSyntax() throws {
        let symbol = process("""
            <SYNTAX TAKE OFF OBJECT (FIND WORNBIT) (HAVE HELD CARRIED) = V-UNWEAR>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "syntax:take-off-object",
            code: """
                Syntax(
                    verb: "take",
                    directObject: Syntax.Object(
                        preposition: "off",
                        where: isBeingWorn,
                        search: [.carried, .have, .held]
                    ),
                    actionRoutine: vUnwear
                )
                """,
            type: .void,
            category: .syntax,
            isCommittable: true
        ))
    }

    func testWaterSyntax() throws {
        let symbol = try factory.init([
            .atom("WATER"),
            .atom("OBJECT"),
            .list([
                .atom("FIND"),
                .atom("SPONGEBIT")
            ]),
            .atom("="),
            .atom("V-POUR-LIQUID"),
            .atom("PRE-WATER"),
            .atom("WATER")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "syntax:water-object",
            code: """
                Syntax(
                    verb: "water",
                    directObject: Syntax.Object(
                        where: spongeBit
                    ),
                    actionRoutine: vPourLiquid,
                    preActionRoutine: preWater
                )
                """,
            type: .void,
            category: .syntax,
            isCommittable: true
        ))
    }

    func testPutSyntax() throws {
        let symbol = try factory.init([
            .atom("PUT"),
            .atom("OBJECT"),
            .list([
                .atom("MANY"),
                .atom("TAKE"),
                .atom("HELD"),
                .atom("CARRIED")
            ]),
            .atom("IN"),
            .atom("OBJECT"),
            .list([
                .atom("FIND"),
                .atom("CONTBIT")
            ]),
            .atom("="),
            .atom("V-PUT-IN"),
            .atom("PRE-PUT-IN")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "syntax:put-object-in-object",
            code: """
                Syntax(
                    verb: "put",
                    directObject: Syntax.Object(
                        search: [.carried, .held, .many, .take]
                    ),
                    indirectObject: Syntax.Object(
                        preposition: "in",
                        where: isContainer
                    ),
                    actionRoutine: vPutIn,
                    preActionRoutine: prePutIn
                )
                """,
            type: .void,
            category: .syntax,
            isCommittable: true
        ))
    }

    func testWakeSyntax() throws {
        let symbol = try factory.init([
            .atom("WAKE"),
            .atom("OBJECT"),
            .list([
                .atom("FIND"),
                .atom("PERSONBIT")
            ]),
            .atom("="),
            .atom("V-WAKE")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "syntax:wake-object",
            code: """
                Syntax(
                    verb: "wake",
                    directObject: Syntax.Object(
                        where: isPerson
                    ),
                    actionRoutine: vWake
                )
                """,
            type: .void,
            category: .syntax,
            isCommittable: true
        ))
    }

    func testWakeUpSyntax() throws {
        let symbol = process("""
            <SYNTAX WAKE UP OBJECT (FIND ACTORBIT) (ON-GROUND IN-ROOM) = V-ALARM>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "syntax:wake-up-object",
            code: """
                Syntax(
                    verb: "wake",
                    directObject: Syntax.Object(
                        preposition: "up",
                        where: isActor,
                        search: [.inRoom, .onGround]
                    ),
                    actionRoutine: vAlarm
                )
                """,
            type: .void,
            category: .syntax,
            isCommittable: true
        ))
    }

    func testWakeKludgeSyntax() throws {
        let symbol = try factory.init([
            .atom("WAKE"),
            .atom("OBJECT"),
            .list([
                .atom("FIND"),
                .atom("PERSONBIT")
            ]),
            .atom("UP"),
            .atom("OBJECT"),
            .list([
                .atom("FIND"),
                .atom("KLUDGEBIT")
            ]),
            .atom("="),
            .atom("V-WAKE")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "syntax:wake-object-up-object",
            code: """
                Syntax(
                    verb: "wake",
                    directObject: Syntax.Object(
                        where: isPerson
                    ),
                    indirectObject: Syntax.Object(
                        preposition: "up",
                        where: shouldKludge
                    ),
                    actionRoutine: vWake
                )
                """,
            type: .void,
            category: .syntax,
            isCommittable: true
        ))
    }

    func testCompetingUps() throws {
        DoWalkTests().setUp()

        process("""
            <DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>

            <SYNTAX WAKE UP OBJECT (FIND ACTORBIT) (ON-GROUND IN-ROOM) = V-ALARM>

            <SYNONYM UP U>

            <ROOM FOREST
                (DESC "Forest")
                (UP "There is no tree here suitable for climbing.")>

            <ROUTINE CONTRIVED-WALK-UP-FCN (WRD)
                <COND (<EQUAL? .WRD ,W?U ,W?UP>
                    <TELL "There are no stairs leading up." CR>)>>
        """)

        XCTAssertNoDifference(
            Game.properties.find("up"),
            Statement(
                id: "up",
                code: "",
                type: .object,
                category: .properties,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            Game.syntax.find("syntax:wake-up-object"),
            Statement(
                id: "syntax:wake-up-object",
                code: """
                    Syntax(
                        verb: "wake",
                        directObject: Syntax.Object(
                            preposition: "up",
                            where: isActor,
                            search: [.inRoom, .onGround]
                        ),
                        actionRoutine: vAlarm
                    )
                    """,
                type: .void,
                category: .syntax,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            Game.syntax.find("synonym:up"),
            Statement(
                id: "synonym:up",
                code: """
                    Syntax.set("up", synonyms: ["u"])
                    """,
                type: .string,
                category: .syntax,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            Game.rooms.find("forest"),
            Statement(
                id: "forest",
                code: """
                    /// The `forest` (FOREST) room.
                    var forest = Room(
                        description: "Forest",
                        directions: [
                            .up: .blocked("There is no tree here suitable for climbing."),
                        ]
                    )
                    """,
                type: .object,
                category: .rooms,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            Game.routines.find("contrivedWalkUpFunc"),
            Statement(
                id: "contrivedWalkUpFunc",
                code: """
                    /// The `contrivedWalkUpFunc` (CONTRIVED-WALK-UP-FCN) routine.
                    func contrivedWalkUpFunc(wrd: Word) {
                        if wrd.equals(.u, .up) {
                            output("There are no stairs leading up.")
                        }
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
