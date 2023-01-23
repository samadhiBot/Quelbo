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
            id: "quit",
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
            id: "contemplateObject",
            code: """
                Syntax(
                    verb: "contemplate",
                    directObject: Syntax.Object(),
                    actionRoutine: vThinkAbout
                )
                """,
            type: .void,
            payload: .init(
                symbols: [.verb("vThinkAbout")]
            ),
            category: .syntax,
            isCommittable: true
        ))
    }

    func testTakeSyntax() throws {
        let symbol = process("""
            <SYNTAX TAKE OBJECT (FIND TAKEBIT) (MANY ON-GROUND IN-ROOM) = V-TAKE>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "takeObject",
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
            payload: .init(
                symbols: [.verb("vTake")]
            ),
            category: .syntax,
            isCommittable: true
        ))
    }

    func testTakeOffSyntax() throws {
        let symbol = process("""
            <SYNTAX TAKE OFF OBJECT (FIND WORNBIT) (HAVE HELD CARRIED) = V-UNWEAR>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "takeOffObject",
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
            payload: .init(
                symbols: [.verb("vUnwear")]
            ),
            category: .syntax,
            isCommittable: true
        ))
    }

    func testWaterSyntax() throws {
        let symbol = process("""
            <SYNTAX WATER OBJECT (FIND SPONGEBIT) = V-POUR-LIQUID PRE-WATER WATER>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "waterObject",
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
            payload: .init(
                symbols: [
                    .verb("preWater"),
                    .verb("vPourLiquid"),
                ]
            ),
            category: .syntax,
            isCommittable: true
        ))
    }

    func testPutSyntax() throws {
        let symbol = process("""
            <SYNTAX PUT OBJECT (MANY TAKE HELD CARRIED) IN OBJECT (FIND CONTBIT) =
                V-PUT-IN PRE-PUT-IN>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "putObjectInObject",
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
            payload: .init(
                symbols: [
                    .verb("prePutIn"),
                    .verb("vPutIn"),
                ]
            ),
            category: .syntax,
            isCommittable: true
        ))
    }

    func testWakeSyntax() throws {
        let symbol = process("""
            <SYNTAX WAKE OBJECT (FIND PERSONBIT) = V-WAKE>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "wakeObject",
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
            payload: .init(
                symbols: [.verb("vWake")]
            ),
            category: .syntax,
            isCommittable: true
        ))
    }

    func testWakeUpSyntax() throws {
        let symbol = process("""
            <SYNTAX WAKE UP OBJECT (FIND ACTORBIT) (ON-GROUND IN-ROOM) = V-ALARM>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "wakeUpObject",
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
            payload: .init(
                symbols: [.verb("vAlarm")]
            ),
            category: .syntax,
            isCommittable: true
        ))
    }

    func testWakeKludgeSyntax() throws {
        let symbol = process("""
            <SYNTAX WAKE OBJECT (FIND PERSONBIT) UP OBJECT
                (FIND KLUDGEBIT) = V-WAKE>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "wakeObjectUpObject",
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
            payload: .init(
                symbols: [.verb("vWake")]
            ),
            category: .syntax,
            isCommittable: true
        ))
    }

    func testCompetingUps() throws {
        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        IsAccessibleTests().sharedSetUp()
        BufferPrintTests().sharedSetUp()
        NotHereTests().sharedSetUp()
        PerformTests().sharedSetUp()
        DoWalkTests().sharedSetUp()

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
            Game.syntax.find("wakeUpObject"),
            Statement(
                id: "wakeUpObject",
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
                payload: .init(
                    symbols: [.verb("vAlarm")]
                ),
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
                        if wrd.equals(Word.u, Word.up) {
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
