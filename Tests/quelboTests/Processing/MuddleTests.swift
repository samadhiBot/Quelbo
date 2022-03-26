//
//  MuddleTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/11/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class MuddleTests: XCTestCase {
    func testConstant() throws {
        XCTAssertNoDifference(
            try Muddle(rawValue: "CONSTANT")?.process([
                .atom("F-BUSY?"),
                .decimal(1)
            ])?.code,
            "let isFBusy: Int = 1"
        )
    }

    func testDefine() throws {
        throw XCTSkip("TODO: test Define")
    }

    func testDefmac() throws {
        throw XCTSkip("TODO: test Defmac")
    }

    func testDirections() throws {
        throw XCTSkip("TODO: test Directions")
    }

    func testFrequentWords() throws {
        throw XCTSkip("TODO: test FrequentWords")
    }

    func testGlobal() throws {
        XCTAssertNoDifference(
            try Muddle(rawValue: "GLOBAL")?.process([
                .atom("SING-SONG"),
                .bool(false)
            ])?.code,
            "var singSong: Bool = false"
        )
    }

    func testGlobalDeclaration() throws {
        XCTAssertNil(try Muddle(rawValue: "GDECL")?.process([
            .list([
                .atom("BEACH-DIG")
            ]),
            .atom("FIX"),
        ]))
    }

    func testInsertFile() throws {
        throw XCTSkip("TODO: test InsertFile")
    }

    func testObject() throws {
        XCTAssertNoDifference(
            try Muddle(rawValue: "OBJECT")?.process([
                .atom("GRATE"),
                .list([
                    .atom("IN"),
                    .atom("LOCAL-GLOBALS")
                ]),
                .list([
                    .atom("SYNONYM"),
                    .atom("GRATE"),
                    .atom("GRATING")
                ]),
                .list([
                    .atom("DESC"),
                    .string("grating")
                ]),
                .list([
                    .atom("FLAGS"),
                    .atom("DOORBIT"),
                    .atom("NDESCBIT"),
                    .atom("INVISIBLE")
                ]),
                .list([
                    .atom("ACTION"),
                    .atom("GRATE-FUNCTION")
                ])
            ])?.code,
            """
            /// The `grate` (GRATE) object.
            var grate = Object(
                name: "grate",
                action: grateFunc,
                attributes: [
                    .door,
                    .invisible,
                    .noDescribe,
                ],
                description: "grating",
                parent: localGlobals,
                synonyms: ["grate", "grating"]
            )
            """
        )
    }

    func testOr() throws {
        throw XCTSkip("TODO: test Or")
    }

    func testPrinc() throws {
        throw XCTSkip("TODO: test Princ")
    }

    func testPropdef() throws {
        throw XCTSkip("TODO: test Propdef")
    }

    func testRoom() throws {
        XCTAssertNoDifference(
            try Muddle(rawValue: "ROOM")?.process([
                .atom("SANDY-CAVE"),
                .commented(.string("was TCAVE")),
                .list([
                    .atom("IN"),
                    .atom("ROOMS")
                ]),
                .list([
                    .atom("LDESC"),
                    .string("This is a sand-filled cave whose exit is to the southwest.")
                ]),
                .list([
                    .atom("DESC"),
                    .string("Sandy Cave")
                ]),
                .list([
                    .atom("SW"),
                    .atom("TO"),
                    .atom("SANDY-BEACH")
                ]),
                .list([
                    .atom("FLAGS"),
                    .atom("RLANDBIT")
                ])
            ])?.code,
            """
            /// The `sandyCave` (SANDY-CAVE) room.
            var sandyCave = Room(
                name: "sandyCave",
                attributes: [.rLand],
                description: "Sandy Cave",
                directions: [
                    .southWest: .to(sandyBeach),
                ],
                longDescription: "This is a sand-filled cave whose exit is to the southwest.",
                parent: rooms
            )
            """
        )
    }

    func testRoutine() throws {
        XCTAssertNoDifference(
            try Muddle(rawValue: "ROUTINE")?.process([
                .atom("TROLL-ROOM-F"),
                .list([
                    .atom("RARG")
                ]),
                .form([
                    .atom("COND"),
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
                    ])
                ])
            ])?.code,
            """
            /// The `trollRoomFunc` (TROLL-ROOM-F) routine.
            func trollRoomFunc(rarg: Int) -> Bool {
                if rarg == World.mEnter && isIn(World.troll, World.here) {
                    thisIsIt(World.troll)
                }
            }
            """
        )
    }

    func testSet() throws {
        throw XCTSkip("TODO: test Set")
    }

    func testSetg() throws {
        throw XCTSkip("TODO: test Setg")
    }

    func testVersion() throws {
        throw XCTSkip("TODO: test Version")
    }

    func testUnknown() throws {
        throw XCTSkip("TODO: test Unknown")
    }
}
