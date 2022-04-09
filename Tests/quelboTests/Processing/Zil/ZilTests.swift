/*
//
//  ZilTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/13/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ZilTests: QuelboTests {
    func testAddAtomAndDecimal() throws {
        let zil = try Zil("+")?.process([
            .atom(",CYCLOWRATH"),
            .decimal(1),
        ])

        XCTAssertNoDifference(zil, "(World.cyclowrath + 1)")
    }

    func testAddAtomAndFunctionResult() throws {
        let zil = try Zil("+")?.process([
            .atom(",BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ])

        XCTAssertNoDifference(zil, "(World.baseScore + otvalFrob())")
    }

    func testAnd() throws {
        let zil = try Zil("AND")?.process([
            .form([
                .atom("VERB?"),
                .atom("BRUSH")
            ]),
            .form([
                .atom("EQUAL?"),
                .atom(",PRSO"),
                .atom(",TEETH")
            ])
        ])

        XCTAssertNoDifference(zil, "isVerb(brush) && World.directObject == World.teeth")
    }

    func testClearFlag() throws {
        let zil = try Zil("FCLEAR")?.process([
            .atom(",MATCH"),
            .atom(",ONBIT")        ])

        XCTAssertNoDifference(zil, "World.match.onbit = false")
    }

    func testCondition() throws {
        let zil = try Zil("COND")?.process([
            .list([
                .form([
                    .atom("AND"),
                    .form([
                        .atom("EQUAL?"),
                        .atom(".RARG"),
                        .atom(",M-ENTER")
                    ]),
                    .form([
                        .atom("IN?"),
                        .atom(",TROLL"),
                        .atom(",HERE")
                    ])
                ]),
                .form([
                    .atom("THIS-IS-IT"),
                    .atom(",TROLL")
                ])
            ])        ])

        XCTAssertNoDifference(zil, """
        if rarg == World.mEnter && isIn(World.troll, World.here) {
            thisIsIt(World.troll)
        }
        """)
    }

    func testCrlf() throws {
        let zil = try Zil("CRLF")?.process([])

        XCTAssertNoDifference(zil, "tell(carriageReturn)")
    }

    func testDivide() throws {
        let zil = try Zil("/")?.process([
            .atom(",BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ])

        XCTAssertNoDifference(zil, "World.baseScore / otvalFrob()")
    }

    func testGet() throws {
        let zil = try Zil("GET")?.process([
            .atom(",HERO-MELEE"),
            .form([
                .atom("-"),
                .atom(".RES"),
                .decimal(1)
            ])
        ])

        XCTAssertNoDifference(zil, "World.heroMelee[(res - 1)]")
    }

    func testGetComputed() throws {
        let zil = try Zil("GET")?.process([
            .form([
                .atom("INT"),
                .atom("I-CURE")
            ]),
            .atom(",C-ENABLED?")
        ])

        XCTAssertNoDifference(zil, "int(iCure)[World.isCEnabled]")
    }

    func testGetProperty() throws {
        let zil = try Zil("GETP")?.process([
            .atom(".F"),
            .atom(",P?TVALUE")
        ])

        XCTAssertNoDifference(zil, "f.takeValue")
    }

    func testIsEqualTo() throws {
        let zil = try Zil("EQUAL?")?.process([
            .atom(",PRSI"),
            .atom(",PUTTY")
        ])

        XCTAssertNoDifference(zil, "World.indirectObject == World.putty")
    }

    func testIsGreaterThan() throws {
        let zil = try Zil("G?")?.process([
            .form([
                .atom("GETP"),
                .atom(".F"),
                .atom(",P?TVALUE")
            ]),
            .decimal(0)
        ])

        XCTAssertNoDifference(zil, "f.takeValue > 0")
    }

    func testIsGreaterThanOrEqualTo() throws {
        let zil = try Zil("G=?")?.process([
            .form([
                .atom("GETP"),
                .atom(".F"),
                .atom(",P?TVALUE")
            ]),
            .decimal(0)
        ])

        XCTAssertNoDifference(zil, "f.takeValue >= 0")
    }

    func testIsLessThan() throws {
        let zil = try Zil("L?")?.process([
            .atom(",DEATHS"),
            .decimal(2),
        ])

        XCTAssertNoDifference(zil, "World.deaths < 2")
    }

    func testIsLessThanAltKeyword() throws {
        let zil = try Zil("LESS?")?.process([
            .atom(",DEATHS"),
            .decimal(2),
        ])

        XCTAssertNoDifference(zil, "World.deaths < 2")
    }

    func testIsLessThanOrEqualTo() throws {
        let zil = try Zil("L=?")?.process([
            .atom(",DEATHS"),
            .decimal(2),
        ])

        XCTAssertNoDifference(zil, "World.deaths <= 2")
    }

    func testIsOne() throws {
        let zil = try Zil("isOne")?.process([
            .atom(",MOVES")
        ])

        XCTAssertNoDifference(zil, "World.moves == 1")
    }

    func testIsZero() throws {
        let zil = try Zil("isZero")?.process([
            .atom(",WATER-LEVEL")
        ])

        XCTAssertNoDifference(zil, "World.waterLevel == 0")
    }

    func testMove() throws {
        let zil = try Zil("MOVE")?.process([
            .atom(",COFFIN"),
            .atom(",EGYPT-ROOM")
        ])

        XCTAssertNoDifference(zil, "move(World.coffin, to: World.egyptRoom)")
    }

    func testMoveToComputedDestination() throws {
        let zil = try Zil("MOVE")?.process([
            .atom(".F"),
            .form([
                .atom("GET"),
                .atom(",ABOVE-GROUND"),
                .form([
                    .atom("RANDOM"),
                    .atom(".L")
                ])
            ])
        ])

        XCTAssertNoDifference(zil, "move(f, to: World.aboveGround[random(l)])")
    }

    func testMultiply() throws {
        let zil = try Zil("*")?.process([
            .atom(",CURE-WAIT"),
            .form([
                .atom("-"),
                .atom(".WD"),
                .decimal(1)
            ])
        ])

        XCTAssertNoDifference(zil, "World.cureWait * (wd - 1)")
    }

    func testOr() throws {
        let zil = try Zil("OR")?.process([
            .form([
                .atom("EQUAL?"),
                .atom(".RES"),
                .atom(",KILLED")
            ]),
            .form([
                .atom("EQUAL?"),
                .atom(".RES"),
                .atom(",SITTING-DUCK")
            ])
        ])

        XCTAssertNoDifference(zil, "res == World.killed || res == World.sittingDuck")
    }

    func testPrintDescription() throws {
        let zil = try Zil("PRINTD")?.process([
            .atom(".OBJ")
        ])

        XCTAssertNoDifference(
            zil,
            """
            output(object.description)
            """
        )
    }

    func testPrintNumber() throws {
        let zil = try Zil("PRINTN")?.process([
            .decimal(42)
        ])

        XCTAssertNoDifference(
            zil,
            """
            output(42)
            """
        )
    }

    func testPrintNumberForm() throws {
        let zil = try Zil("PRINTN")?.process([
            .form([
                .atom("*"),
                .decimal(6),
                .decimal(7),
            ])
        ])

        XCTAssertNoDifference(
            zil,
            """
            output(6 * 7)
            """
        )
    }

    func testPrintStringAtom() throws {
        let zil = try Zil("PRINT")?.process([
            .atom(".MESSAGE")
        ])

        XCTAssertNoDifference(
            zil,
            """
            output(message)
            """
        )
    }

    func testPrintStringString() throws {
        let zil = try Zil("PRINT")?.process([
            .string("Message")
        ])

        XCTAssertNoDifference(
            zil,
            """
            output("Message")
            """
        )
    }

    func testPrintStringCR() throws {
        let zil = try Zil("PRINTR")?.process([
            .string("No more bottles of beer on the wall!")
        ])

        XCTAssertNoDifference(
            zil,
            """
            output(
                "No more bottles of beer on the wall!",
                withCarriageReturn: true
            )
            """
        )
    }

    func testPrintTable() throws {
        XCTAssertThrowsError(
            try Zil("PRINTF")?.process([])
        )
    }

    func testProgramBlock() throws {
        let zil = try Zil("PROG")?.process([
            .list([
            ]),
            .form([
                .atom("SCORE-UPD"),
                .decimal(-10)
            ]),
            .form([
                .atom("TELL"),
                .string("""
                    ****  You have died  ****
                """)
            ])
        ])

        XCTAssertNoDifference(zil, #"""
            do {
                scoreUpd(-10)
                tell(["\"    ****  You have died  ****\""])
            }
            """#
        )
    }

    func testPutProperty() throws {
        Game.definitions.append(.init(
            name: "deadFunc",
            code: "",
            dataType: .void,
            defType: .routine,
            isMutable: false
        ))

        let zil = try Zil("PUTP")?.process([
            .atom(",WINNER"),
            .atom(",P?ACTION"),
            .atom("DEAD-FUNCTION")
        ])

        XCTAssertNoDifference(zil, "World.winner.action = deadFunc()")
    }

    func testPutPropertyString() throws {
        let zil = try Zil("PUTP")?.process([
            .atom(",TROLL"),
            .atom(",P?LDESC"),
            .string(#"""
                A nasty-looking troll, brandishing a bloody axe, blocks \
                all passages out of the room.
                """#)
        ])

        XCTAssertNoDifference(zil, #"""
            World.troll.longDescription = """
                A nasty-looking troll, brandishing a bloody axe, blocks \
                all passages out of the room.
                """
            """#
        )
    }

    func testRepeating() throws {
        let zil = try Zil("REPEAT")?.process([
            .list([
            ]),
            .form([
                .atom("COND"),
                .list([
                    .form([
                        .atom("L?"),
                        .form([
                            .atom("SET"),
                            .atom("N"),
                            .form([
                                .atom("-"),
                                .atom(".N"),
                                .decimal(1)
                            ])
                        ]),
                        .decimal(1)
                    ]),
                    .form([
                        .atom("RETURN")
                    ])
                ]),
                .list([
                    .atom("T"),
                    .form([
                        .atom("TELL"),
                        .string("    Fweep!"),
                        .atom("CR")
                    ])
                ])
            ])
        ])

        XCTAssertNoDifference(zil, """
            repeat {
                if set(&n, to: (n - 1)) < 1 {
                    break
                } else {
                    tell(
                        "    Fweep!",
                        carriageReturn
                    )
                }
            } while true
            """
        )
    }

    func testReturnFalse() throws {
        let zil = try Zil("RFALSE")?.process([])

        XCTAssertNoDifference(zil, "return false")
    }

    func testReturnTrue() throws {
        let zil = try Zil("RTRUE")?.process([])

        XCTAssertNoDifference(zil, "return true")
    }

    func testSetToLiteral() throws {
        let zil = try Zil("SET")?.process([
            .atom("ROBBED?"),
            .bool(true),
        ])

        XCTAssertNoDifference(zil, "set(&isRobbed, to: true)")
    }

    func testSetVariableCalledT() throws {
        let zil = try Zil("SET")?.process([
            .atom("T"),
            .form([
                .atom("GETPT"),
                .atom(",HERE"),
                .atom(".P")
            ])
        ])

        XCTAssertNoDifference(zil, "set(&t, to: getpt(World.here, p))")
    }

    func testSetToLocalVariable() throws {
        let zil = try Zil("SET")?.process([
            .atom("X"),
            .atom(".N"),
        ])

        XCTAssertNoDifference(zil, "set(&x, to: n)")
    }

    func testSetToFunctionResult() throws {
        let zil = try Zil("SET")?.process([
            .atom("N"),
            .form([
                .atom("NEXT?"),
                .atom(".X")
            ]),
        ])

        XCTAssertNoDifference(zil, "set(&n, to: isNext(x))")
    }

    func testSetToModifiedSelf() throws {
        let zil = try Zil("SET")?.process([
            .atom("N"),
            .form([
                .atom("-"),
                .atom(".N"),
                .decimal(1)
            ])
        ])

        XCTAssertNoDifference(zil, "set(&n, to: (n - 1))")
    }

    func testSetFlag() throws {
        let zil = try Zil("FSET")?.process([
            .atom(",AXE"),
            .atom(",WEAPONBIT")
        ])

        XCTAssertNoDifference(zil, "World.axe.weaponbit = true")
    }

    func testSetGlobal() throws {
        let zil = try Zil("SETG")?.process([
            .atom("SCORE"),
            .form([
                .atom("+"),
                .atom(",BASE-SCORE"),
                .form([
                    .atom("OTVAL-FROB")
                ])
            ])
        ])

        XCTAssertNoDifference(zil, "World.score = (World.baseScore + otvalFrob())")
    }

    func testSubtract() throws {
        let zil = try Zil("-")?.process([
            .atom(",LOAD-ALLOWED"),
            .decimal(20)
        ])
        XCTAssertNoDifference(zil, "(World.loadAllowed - 20)")
    }

    func testSubtractSingleArgument() throws {
        let zil = try Zil("-")?.process([
            .form([
                .atom("GETP"),
                .atom(",THIEF"),
                .atom(",P?STRENGTH")
            ])
        ])

        XCTAssertNoDifference(zil, "-World.thief.strength")
    }

    func testTell() throws {
        let zil = try Zil("TELL")?.process([
            .string("The chain is secure."),
            .atom("CR"),
        ])

        XCTAssertNoDifference(zil, """
            tell(
                "The chain is secure.",
                carriageReturn
            )
            """
        )
    }

    func testMultilineTell() throws {
        let zil = try Zil("TELL")?.process([
            .string(
                #"""
                You hear a scream of anguish as you violate the robber's hideaway. \
                Using passages unknown to you, he rushes to its defense."),
                """#
            ),
            .atom("CR")
        ])

        XCTAssertNoDifference(zil, #"""
            tell(
                """
                    You hear a scream of anguish as you violate the robber's \
                    hideaway. \
                    Using passages unknown to you, he rushes to its defense."),
                    """,
                carriageReturn
            )
            """#
        )
    }

    func testInterpolatingTell() throws {
        let zil = try Zil("TELL")?.process([
            .string("The thief places the "),
            .atom("D"),
            .atom(",PRSO"),
            .string(" in his bag and thanks you politely."),
            .atom("CR")
        ])

        XCTAssertNoDifference(zil, #"""
            tell(
                "The thief places the ",
                World.directObject.description,
                " in his bag and thanks you politely.",
                carriageReturn
            )
            """#
        )
    }
}
*/
