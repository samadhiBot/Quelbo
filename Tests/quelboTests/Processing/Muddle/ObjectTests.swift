//
//  ObjectTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/17/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ObjectTests: XCTestCase {
    func testWhiteHouse() throws {
        var object = Object(.object, [
            .atom("WHITE-HOUSE"),
            .list([
                .atom("IN"),
                .atom("LOCAL-GLOBALS")
            ]),
            .list([
                .atom("SYNONYM"),
                .atom("HOUSE")
            ]),
            .list([
                .atom("ADJECTIVE"),
                .atom("WHITE"),
                .atom("BEAUTI"),
                .atom("COLONI")
            ]),
            .list([
                .atom("DESC"),
                .string("white house")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("NDESCBIT")
            ]),
            .list([
                .atom("ACTION"),
                .atom("WHITE-HOUSE-F")
            ])
        ])

        XCTAssertNoDifference(try object.process(), .init(
            name: "whiteHouse",
            code: """
                /// The `whiteHouse` (WHITE-HOUSE) object.
                var whiteHouse = Object(
                    name: "whiteHouse",
                    action: whiteHouseFunc,
                    adjectives: [
                        "beauti",
                        "coloni",
                        "white",
                    ],
                    attributes: [.noDescribe],
                    description: "white house",
                    parent: localGlobals,
                    synonyms: ["house"]
                )
                """,
            dataType: .object,
            defType: .object,
            isMutable: true
        ))
    }

    func testBrokenEgg() throws {
        var object = Object(.object, [
            .atom("BROKEN-EGG"),
            .list([
                .atom("SYNONYM"),
                .atom("EGG"),
                .atom("TREASURE")
            ]),
            .list([
                .atom("ADJECTIVE"),
                .atom("BROKEN"),
                .atom("BIRDS"),
                .atom("ENCRUSTED"),
                .atom("JEWEL")
            ]),
            .list([
                .atom("DESC"),
                .string("broken jewel-encrusted egg")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("TAKEBIT"),
                .atom("CONTBIT"),
                .atom("OPENBIT")
            ]),
            .list([
                .atom("CAPACITY"),
                .decimal(6)
            ]),
            .list([
                .atom("TVALUE"),
                .decimal(2)
            ]),
            .list([
                .atom("LDESC"),
                .string("There is a somewhat ruined egg here.")
            ])
        ])

        XCTAssertNoDifference(try object.process(), .init(
            name: "brokenEgg",
            code: """
                /// The `brokenEgg` (BROKEN-EGG) object.
                var brokenEgg = Object(
                    name: "brokenEgg",
                    adjectives: [
                        "birds",
                        "broken",
                        "encrusted",
                        "jewel",
                    ],
                    attributes: [
                        .container,
                        .openable,
                        .takeable,
                    ],
                    capacity: 6,
                    description: "broken jewel-encrusted egg",
                    longDescription: "There is a somewhat ruined egg here.",
                    synonyms: ["egg", "treasure"],
                    takeValue: 2
                )
                """,
            dataType: .object,
            defType: .object,
            isMutable: true
        ))
    }

    func testBat() throws {
        var object = Object(.object, [
            .atom("BAT"),
            .list([
                .atom("IN"),
                .atom("BAT-ROOM")
            ]),
            .list([
                .atom("SYNONYM"),
                .atom("BAT"),
                .atom("VAMPIRE")
            ]),
            .list([
                .atom("ADJECTIVE"),
                .atom("VAMPIRE"),
                .atom("DERANGED")
            ]),
            .list([
                .atom("DESC"),
                .string("bat")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("ACTORBIT"),
                .atom("TRYTAKEBIT")
            ]),
            .list([
                .atom("DESCFCN"),
                .atom("BAT-D")
            ]),
            .list([
                .atom("ACTION"),
                .atom("BAT-F")
            ])
        ])

        XCTAssertNoDifference(try object.process(), .init(
            name: "bat",
            code: """
                /// The `bat` (BAT) object.
                var bat = Object(
                    name: "bat",
                    action: batFunc,
                    adjectives: ["deranged", "vampire"],
                    attributes: [.actor, .tryTake],
                    description: "bat",
                    descriptionFunction: batD,
                    parent: batRoom,
                    synonyms: ["bat", "vampire"]
                )
                """,
            dataType: .object,
            defType: .object,
            isMutable: true
        ))
    }

    func testSkull() throws {
        var object = Object(.object, [
            .atom("SKULL"),
            .list([
                .atom("IN"),
                .atom("LAND-OF-LIVING-DEAD")
            ]),
            .list([
                .atom("SYNONYM"),
                .atom("SKULL"),
                .atom("HEAD"),
                .atom("TREASURE")
            ]),
            .list([
                .atom("ADJECTIVE"),
                .atom("CRYSTAL")
            ]),
            .list([
                .atom("DESC"),
                .string("crystal skull")
            ]),
            .list([
                .atom("FDESC"),
                .string("""
                    Lying in one corner of the room is a beautifully carved crystal skull. \
                    It appears to be grinning at you rather nastily.
                    """)
            ]),
            .list([
                .atom("FLAGS"),
                .atom("TAKEBIT")
            ]),
            .list([
                .atom("VALUE"),
                .decimal(10)
            ]),
            .list([
                .atom("TVALUE"),
                .decimal(10)
            ])
        ])

        XCTAssertNoDifference(try object.process(), .init(
            name: "skull",
            code: #"""
                /// The `skull` (SKULL) object.
                var skull = Object(
                    name: "skull",
                    adjectives: ["crystal"],
                    attributes: [.takeable],
                    description: "crystal skull",
                    firstDescription: """
                        Lying in one corner of the room is a beautifully carved \
                        crystal skull. It appears to be grinning at you rather \
                        nastily.
                        """,
                    parent: landOfLivingDead,
                    synonyms: [
                        "head",
                        "skull",
                        "treasure",
                    ],
                    takeValue: 10,
                    value: 10
                )
                """#,
            dataType: .object,
            defType: .object,
            isMutable: true
        ))
    }

    func testWater() throws {
        var object = Object(.object, [
            .atom("WATER"),
            .list([
                .atom("IN"),
                .atom("BOTTLE")
            ]),
            .list([
                .atom("SYNONYM"),
                .atom("WATER"),
                .atom("QUANTITY"),
                .atom("LIQUID"),
                .atom("H2O")
            ]),
            .list([
                .atom("DESC"),
                .string("quantity of water")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("TRYTAKEBIT"),
                .atom("TAKEBIT"),
                .atom("DRINKBIT")
            ]),
            .list([
                .atom("ACTION"),
                .atom("WATER-F")
            ]),
            .list([
                .atom("SIZE"),
                .decimal(4)
            ])
        ])

        XCTAssertNoDifference(try object.process(), .init(
            name: "water",
            code: """
                /// The `water` (WATER) object.
                var water = Object(
                    name: "water",
                    action: waterFunc,
                    attributes: [
                        .drinkable,
                        .takeable,
                        .tryTake,
                    ],
                    description: "quantity of water",
                    parent: bottle,
                    size: 4,
                    synonyms: [
                        "h2o",
                        "liquid",
                        "quantity",
                        "water",
                    ]
                )
                """,
            dataType: .object,
            defType: .object,
            isMutable: true
        ))
    }

    func testTroll() throws {
        var object = Object(.object, [
            .atom("TROLL"),
            .list([
                .atom("IN"),
                .atom("TROLL-ROOM")
            ]),
            .list([
                .atom("SYNONYM"),
                .atom("TROLL")
            ]),
            .list([
                .atom("ADJECTIVE"),
                .atom("NASTY")
            ]),
            .list([
                .atom("DESC"),
                .string("troll")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("ACTORBIT"),
                .atom("OPENBIT"),
                .atom("TRYTAKEBIT")
            ]),
            .list([
                .atom("ACTION"),
                .atom("TROLL-FCN")
            ]),
            .list([
                .atom("LDESC"),
                .string("""
                    A nasty-looking troll, brandishing a bloody axe, blocks all passages \
                    out of the room.
                    """)
            ]),
            .list([
                .atom("STRENGTH"),
                .decimal(2)
            ])
        ])

        XCTAssertNoDifference(try object.process(), .init(
            name: "troll",
            code: #"""
                /// The `troll` (TROLL) object.
                var troll = Object(
                    name: "troll",
                    action: trollFunc,
                    adjectives: ["nasty"],
                    attributes: [
                        .actor,
                        .openable,
                        .tryTake,
                    ],
                    description: "troll",
                    longDescription: """
                        A nasty-looking troll, brandishing a bloody axe, blocks all \
                        passages out of the room.
                        """,
                    parent: trollRoom,
                    strength: 2,
                    synonyms: ["troll"]
                )
                """#,
            dataType: .object,
            defType: .object,
            isMutable: true
        ))
    }

    func testAdvertisement() throws {
        var object = Object(.object, [
            .atom("ADVERTISEMENT"),
            .list([
                .atom("IN"),
                .atom("MAILBOX")
            ]),
            .list([
                .atom("SYNONYM"),
                .atom("ADVERTISEMENT"),
                .atom("LEAFLET"),
                .atom("BOOKLET"),
                .atom("MAIL")
            ]),
            .list([
                .atom("ADJECTIVE"),
                .atom("SMALL")
            ]),
            .list([
                .atom("DESC"),
                .string("leaflet")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("READBIT"),
                .atom("TAKEBIT"),
                .atom("BURNBIT")
            ]),
            .list([
                .atom("LDESC"),
                .string("A small leaflet is on the ground.")
            ]),
            .list([
                .atom("TEXT"),
                .string("""
                    "WELCOME TO ZORK!

                    ZORK is a game of adventure, danger, and low cunning. In it you \
                    will explore some of the most amazing territory ever seen by mortals. \
                    No computer should be without one!"
                    """)
            ]),
            .list([
                .atom("SIZE"),
                .decimal(2)
            ])
        ])

        XCTAssertNoDifference(try object.process(), .init(
            name: "advertisement",
            code: #"""
                /// The `advertisement` (ADVERTISEMENT) object.
                var advertisement = Object(
                    name: "advertisement",
                    adjectives: ["small"],
                    attributes: [
                        .burnable,
                        .readable,
                        .takeable,
                    ],
                    description: "leaflet",
                    longDescription: "A small leaflet is on the ground.",
                    parent: mailbox,
                    size: 2,
                    synonyms: [
                        "advertisement",
                        "booklet",
                        "leaflet",
                        "mail",
                    ],
                    text: """
                        "WELCOME TO ZORK!
                        *
                        ZORK is a game of adventure, danger, and low cunning. In it \
                        you will explore some of the most amazing territory ever \
                        seen by mortals. No computer should be without one!"
                        """
                )
                """#.replacingOccurrences(of: "*", with: ""),
            dataType: .object,
            defType: .object,
            isMutable: true
        ))
    }

    func testTrophyCase() throws {
        var object = Object(.object, [
            .atom("TROPHY-CASE"),
            .commented(.string("first obj so L.R. desc looks right.")),
            .list([
                .atom("IN"),
                .atom("LIVING-ROOM")
            ]),
            .list([
                .atom("SYNONYM"),
                .atom("CASE")
            ]),
            .list([
                .atom("ADJECTIVE"),
                .atom("TROPHY")
            ]),
            .list([
                .atom("DESC"),
                .string("trophy case")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("TRANSBIT"),
                .atom("CONTBIT"),
                .atom("NDESCBIT"),
                .atom("TRYTAKEBIT"),
                .atom("SEARCHBIT")
            ]),
            .list([
                .atom("ACTION"),
                .atom("TROPHY-CASE-FCN")
            ]),
            .list([
                .atom("CAPACITY"),
                .decimal(10000)
            ])
        ])

        XCTAssertNoDifference(try object.process(), .init(
            name: "trophyCase",
            code: """
                /// The `trophyCase` (TROPHY-CASE) object.
                var trophyCase = Object(
                    name: "trophyCase",
                    action: trophyCaseFunc,
                    adjectives: ["trophy"],
                    attributes: [
                        .container,
                        .noDescribe,
                        .searchable,
                        .trans,
                        .tryTake,
                    ],
                    capacity: 10000,
                    description: "trophy case",
                    parent: livingRoom,
                    synonyms: ["case"]
                )
                """,
            dataType: .object,
            defType: .object,
            isMutable: true
        ))
    }

    func testGlobalObjects() throws {
        var object = Object(.object, [
            .atom("GLOBAL-OBJECTS"),
            .list([
                .atom("FLAGS"),
                .atom("RMUNGBIT"),
                .atom("INVISIBLE"),
                .atom("TOUCHBIT"),
                .atom("SURFACEBIT"),
                .atom("TRYTAKEBIT"),
                .atom("OPENBIT"),
                .atom("SEARCHBIT"),
                .atom("TRANSBIT"),
                .atom("ONBIT"),
                .atom("RLANDBIT"),
                .atom("FIGHTBIT"),
                .atom("STAGGERED"),
                .atom("WEARBIT")
            ])
        ])

        XCTAssertNoDifference(try object.process(), .init(
            name: "globalObjects",
            code: """
                /// The `globalObjects` (GLOBAL-OBJECTS) object.
                var globalObjects = Object(
                    name: "globalObjects",
                    attributes: [
                        .fightable,
                        .invisible,
                        .on,
                        .openable,
                        .rLand,
                        .rMung,
                        .searchable,
                        .staggered,
                        .surface,
                        .touchable,
                        .trans,
                        .tryTake,
                        .wearable,
                    ]
                )
                """,
            dataType: .object,
            defType: .object,
            isMutable: true
        ))
    }

    func testLocalGlobals() throws {
        var object = Object(.object, [
            .atom("LOCAL-GLOBALS"),
            .list([
                .atom("IN"),
                .atom("GLOBAL-OBJECTS")
            ]),
            .list([
                .atom("SYNONYM"),
                .atom("ZZMGCK")
            ]),
            .list([
                .atom("DESCFCN"),
                .atom("PATH-OBJECT")
            ]),
            .list([
                .atom("GLOBAL"),
                .atom("GLOBAL-OBJECTS")
            ]),
            .list([
                .atom("ADVFCN"),
                .decimal(0)
            ]),
            .list([
                .atom("FDESC"),
                .string("F")
            ]),
            .list([
                .atom("LDESC"),
                .string("F")
            ]),
            .list([
                .atom("PSEUDO"),
                .string("FOOBAR"),
                .atom("V-WALK")
            ]),
            .list([
                .atom("CONTFCN"),
                .decimal(0)
            ]),
            .list([
                .atom("VTYPE"),
                .decimal(1)
            ]),
            .list([
                .atom("SIZE"),
                .decimal(0)
            ]),
            .list([
                .atom("CAPACITY"),
                .decimal(0)
            ])
        ])

        XCTAssertNoDifference(try object.process(), .init(
            name: "localGlobals",
            code: """
                /// The `localGlobals` (LOCAL-GLOBALS) object.
                var localGlobals = Object(
                    name: "localGlobals",
                    capacity: 0,
                    descriptionFunction: pathObject,
                    firstDescription: "F",
                    globals: [globalObjects],
                    longDescription: "F",
                    parent: globalObjects,
                    pseudos: [
                        "foobar": vWalk
                    ],
                    size: 0,
                    synonyms: ["zzmgck"],
                    vType: 1
                )
                """,
            dataType: .object,
            defType: .object,
            isMutable: true
        ))
    }

    func testAdventurer() throws {
        var object = Object(.object, [
            .atom("ADVENTURER"),
            .list([
                .atom("SYNONYM"),
                .atom("ADVENTURER")
            ]),
            .list([
                .atom("DESC"),
                .string("cretin")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("NDESCBIT"),
                .atom("INVISIBLE"),
                .atom("SACREDBIT"),
                .atom("ACTORBIT")
            ]),
            .list([
                .atom("STRENGTH"),
                .decimal(0)
            ]),
            .list([
                .atom("ACTION"),
                .decimal(0)
            ])
        ])

        XCTAssertNoDifference(try object.process(), .init(
            name: "adventurer",
            code: """
                /// The `adventurer` (ADVENTURER) object.
                var adventurer = Object(
                    name: "adventurer",
                    action: 0,
                    attributes: [
                        .actor,
                        .invisible,
                        .noDescribe,
                        .sacred,
                    ],
                    description: "cretin",
                    strength: 0,
                    synonyms: ["adventurer"]
                )
                """,
            dataType: .object,
            defType: .object,
            isMutable: true
        ))
    }
}
