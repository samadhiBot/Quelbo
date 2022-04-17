//
//  ObjectTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/17/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ObjectTests: QuelboTests {
    let factory = Factories.Object.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("OBJECT"))
    }

    func testWhiteHouse() throws {
        let symbol = try factory.init([
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
        ]).process()

        let expected = Symbol(
            id: "whiteHouse",
            code: """
                /// The `whiteHouse` (WHITE-HOUSE) object.
                var whiteHouse = Object(
                    action: whiteHouseFunc,
                    adjectives: [
                        "white",
                        "beauti",
                        "coloni"
                    ],
                    description: "white house",
                    flags: [ndescBit],
                    location: localGlobals,
                    synonyms: ["house"]
                )
                """,
            type: .object,
            category: .objects,
            children: [
                Symbol(
                    id: "location",
                    code: "location: localGlobals",
                    type: .object,
                    children: [
                        Symbol("localGlobals", type: .object)
                    ]
                ),
                Symbol(
                    id: "synonyms",
                    code: "synonyms: [\"house\"]",
                    type: .array(.string),
                    children: [
                        Symbol("house", type: .string)
                    ]
                ),
                Symbol(
                    id: "adjectives",
                    code: """
                         adjectives: [
                             "white",
                             "beauti",
                             "coloni"
                         ]
                         """,
                    type: .array(.string),
                    children: [
                        Symbol("white", type: .string),
                        Symbol("beauti", type: .string),
                        Symbol("coloni", type: .string)
                    ]
                ),
                Symbol(
                    id: "description",
                    code: "description: \"white house\"",
                    type: .string,
                    children: [
                        Symbol("\"white house\"", type: .string)
                    ]
                ),
                Symbol(
                    id: "flags",
                    code: "flags: [ndescBit]",
                    type: .array(.bool),
                    children: [
                        Symbol("ndescBit", type: .bool)
                    ]
                ),
                Symbol(
                    id: "action",
                    code: "action: whiteHouseFunc",
                    type: .routine,
                    children: [
                        Symbol("whiteHouseFunc", type: .routine)
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("whiteHouse"), expected)
    }

    func testBrokenEgg() throws {
        let symbol = try factory.init([
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
        ]).process()

        let expected = Symbol(
            id: "brokenEgg",
            code: """
                /// The `brokenEgg` (BROKEN-EGG) object.
                var brokenEgg = Object(
                    adjectives: [
                        "broken",
                        "birds",
                        "encrusted",
                        "jewel"
                    ],
                    capacity: 6,
                    description: "broken jewel-encrusted egg",
                    flags: [
                        takeBit,
                        contBit,
                        openBit
                    ],
                    longDescription: "There is a somewhat ruined egg here.",
                    synonyms: [
                        "egg",
                        "treasure"
                    ],
                    takeValue: 2
                )
                """,
            type: .object,
            category: .objects,
            children: [
                Symbol(
                    id: "synonyms",
                    code: """
                         synonyms: [
                             "egg",
                             "treasure"
                         ]
                         """,
                    type: .array(.string),
                    children: [
                        Symbol(
                            id: "egg",
                            code: "egg",
                            type: .string
                        ),
                        Symbol(
                            id: "treasure",
                            code: "treasure",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "adjectives",
                    code: """
                         adjectives: [
                             "broken",
                             "birds",
                             "encrusted",
                             "jewel"
                         ]
                         """,
                    type: .array(.string),
                    children: [
                        Symbol(
                            id: "broken",
                            code: "broken",
                            type: .string
                        ),
                        Symbol(
                            id: "birds",
                            code: "birds",
                            type: .string
                        ),
                        Symbol(
                            id: "encrusted",
                            code: "encrusted",
                            type: .string
                        ),
                        Symbol(
                            id: "jewel",
                            code: "jewel",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "description",
                    code: "description: \"broken jewel-encrusted egg\"",
                    type: .string,
                    children: [
                        Symbol(
                            id: "\"broken jewel-encrusted egg\"",
                            code: "\"broken jewel-encrusted egg\"",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "flags",
                    code: """
                         flags: [
                             takeBit,
                             contBit,
                             openBit
                         ]
                         """,
                    type: .array(.bool),
                    children: [
                        Symbol(
                            id: "takeBit",
                            code: "takeBit",
                            type: .bool
                        ),
                        Symbol(
                            id: "contBit",
                            code: "contBit",
                            type: .bool
                        ),
                        Symbol(
                            id: "openBit",
                            code: "openBit",
                            type: .bool
                        )
                    ]
                ),
                Symbol(
                    id: "capacity",
                    code: "capacity: 6",
                    type: .int,
                    children: [
                        Symbol(
                            id: "6",
                            code: "6",
                            type: .int
                        )
                    ]
                ),
                Symbol(
                    id: "takeValue",
                    code: "takeValue: 2",
                    type: .int,
                    children: [
                        Symbol(
                            id: "2",
                            code: "2",
                            type: .int
                        )
                    ]
                ),
                Symbol(
                    id: "longDescription",
                    code: "longDescription: \"There is a somewhat ruined egg here.\"",
                    type: .string,
                    children: [
                        Symbol(
                            id: "\"There is a somewhat ruined egg here.\"",
                            code: "\"There is a somewhat ruined egg here.\"",
                            type: .string
                        )
                    ]
                )

            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("brokenEgg"), expected)
    }

    func testBat() throws {
        let symbol = try factory.init([
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
        ]).process()

        let expected = Symbol(
            id: "bat",
            code: """
                /// The `bat` (BAT) object.
                var bat = Object(
                    action: batFunc,
                    adjectives: [
                        "vampire",
                        "deranged"
                    ],
                    description: "bat",
                    descriptionFunction: batD,
                    flags: [
                        actorBit,
                        trytakeBit
                    ],
                    location: batRoom,
                    synonyms: [
                        "bat",
                        "vampire"
                    ]
                )
                """,
            type: .object,
            category: .objects,
            children: [
                Symbol(
                    id: "location",
                    code: "location: batRoom",
                    type: .object,
                    children: [
                        Symbol(
                            id: "batRoom",
                            code: "batRoom",
                            type: .object
                        )
                    ]
                ),
                Symbol(
                    id: "synonyms",
                    code: """
                         synonyms: [
                             "bat",
                             "vampire"
                         ]
                         """,
                    type: .array(.string),
                    children: [
                        Symbol(
                            id: "bat",
                            code: "bat",
                            type: .string
                        ),
                        Symbol(
                            id: "vampire",
                            code: "vampire",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "adjectives",
                    code: """
                         adjectives: [
                             "vampire",
                             "deranged"
                         ]
                         """,
                    type: .array(.string),
                    children: [
                        Symbol(
                            id: "vampire",
                            code: "vampire",
                            type: .string
                        ),
                        Symbol(
                            id: "deranged",
                            code: "deranged",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "description",
                    code: "description: \"bat\"",
                    type: .string,
                    children: [
                        Symbol(
                            id: "\"bat\"",
                            code: "\"bat\"",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "flags",
                    code: """
                         flags: [
                             actorBit,
                             trytakeBit
                         ]
                         """,
                    type: .array(.bool),
                    children: [
                        Symbol(
                            id: "actorBit",
                            code: "actorBit",
                            type: .bool
                        ),
                        Symbol(
                            id: "trytakeBit",
                            code: "trytakeBit",
                            type: .bool
                        )
                    ]
                ),
                Symbol(
                    id: "descriptionFunction",
                    code: "descriptionFunction: batD",
                    type: .routine,
                    children: [
                        Symbol(
                            id: "batD",
                            code: "batD",
                            type: .routine
                        )
                    ]
                ),
                Symbol(
                    id: "action",
                    code: "action: batFunc",
                    type: .routine,
                    children: [
                        Symbol(
                            id: "batFunc",
                            code: "batFunc",
                            type: .routine
                        )
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("bat"), expected)
    }

    func testSkull() throws {
        let symbol = try factory.init([
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
        ]).process()

        let expected = Symbol(
            id: "skull",
            code: #"""
                /// The `skull` (SKULL) object.
                var skull = Object(
                    adjectives: ["crystal"],
                    description: "crystal skull",
                    firstDescription: """
                        Lying in one corner of the room is a beautifully carved \
                        crystal skull. It appears to be grinning at you rather \
                        nastily.
                        """,
                    flags: [takeBit],
                    location: landOfLivingDead,
                    synonyms: [
                        "skull",
                        "head",
                        "treasure"
                    ],
                    takeValue: 10,
                    value: 10
                )
                """#,
            type: .object,
            category: .objects,
            children: [
                Symbol(
                    id: "location",
                    code: "location: landOfLivingDead",
                    type: .object,
                    children: [
                        Symbol(
                            id: "landOfLivingDead",
                            code: "landOfLivingDead",
                            type: .object
                        )
                    ]
                ),
                Symbol(
                    id: "synonyms",
                    code: """
                    synonyms: [
                        "skull",
                        "head",
                        "treasure"
                    ]
                    """,
                    type: .array(.string),
                    children: [
                        Symbol(
                            id: "skull",
                            code: "skull",
                            type: .string
                        ),
                        Symbol(
                            id: "head",
                            code: "head",
                            type: .string
                        ),
                        Symbol(
                            id: "treasure",
                            code: "treasure",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "adjectives",
                    code: "adjectives: [\"crystal\"]",
                    type: .array(.string),
                    children: [
                        Symbol(
                            id: "crystal",
                            code: "crystal",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "description",
                    code: "description: \"crystal skull\"",
                    type: .string,
                    children: [
                        Symbol(
                            id: "\"crystal skull\"",
                            code: "\"crystal skull\"",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "firstDescription",
                    code: #"""
                    firstDescription: """
                        Lying in one corner of the room is a beautifully carved \
                        crystal skull. It appears to be grinning at you rather \
                        nastily.
                        """
                    """#,
                    type: .string,
                    children: [
                        Symbol(
                            id: #"""
                        """
                            Lying in one corner of the room is a beautifully carved \
                            crystal skull. It appears to be grinning at you rather \
                            nastily.
                            """
                        """#,
                            code: #"""
                        """
                            Lying in one corner of the room is a beautifully carved \
                            crystal skull. It appears to be grinning at you rather \
                            nastily.
                            """
                        """#,
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "flags",
                    code: "flags: [takeBit]",
                    type: .array(.bool),
                    children: [
                        Symbol(
                            id: "takeBit",
                            code: "takeBit",
                            type: .bool
                        )
                    ]
                ),
                Symbol(
                    id: "value",
                    code: "value: 10",
                    type: .int,
                    children: [
                        Symbol(
                            id: "10",
                            code: "10",
                            type: .int
                        )
                    ]
                ),
                Symbol(
                    id: "takeValue",
                    code: "takeValue: 10",
                    type: .int,
                    children: [
                        Symbol(
                            id: "10",
                            code: "10",
                            type: .int
                        )
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("skull"), expected)
    }

    func testWater() throws {
        let symbol = try factory.init([
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
        ]).process()

        let expected = Symbol(
            id: "water",
            code: """
                /// The `water` (WATER) object.
                var water = Object(
                    action: waterFunc,
                    description: "quantity of water",
                    flags: [
                        trytakeBit,
                        takeBit,
                        drinkBit
                    ],
                    location: bottle,
                    size: 4,
                    synonyms: [
                        "water",
                        "quantity",
                        "liquid",
                        "h2o"
                    ]
                )
                """,
            type: .object,
            category: .objects,
            children: [
                Symbol(
                    id: "location",
                    code: "location: bottle",
                    type: .object,
                    children: [
                        Symbol(
                            id: "bottle",
                            code: "bottle",
                            type: .object
                        )
                    ]
                ),
                Symbol(
                    id: "synonyms",
                    code: """
                         synonyms: [
                             "water",
                             "quantity",
                             "liquid",
                             "h2o"
                         ]
                         """,
                    type: .array(.string),
                    children: [
                        Symbol(
                            id: "water",
                            code: "water",
                            type: .string
                        ),
                        Symbol(
                            id: "quantity",
                            code: "quantity",
                            type: .string
                        ),
                        Symbol(
                            id: "liquid",
                            code: "liquid",
                            type: .string
                        ),
                        Symbol(
                            id: "h2o",
                            code: "h2o",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "description",
                    code: "description: \"quantity of water\"",
                    type: .string,
                    children: [
                        Symbol(
                            id: "\"quantity of water\"",
                            code: "\"quantity of water\"",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "flags",
                    code: """
                         flags: [
                             trytakeBit,
                             takeBit,
                             drinkBit
                         ]
                         """,
                    type: .array(.bool),
                    children: [
                        Symbol(
                            id: "trytakeBit",
                            code: "trytakeBit",
                            type: .bool
                        ),
                        Symbol(
                            id: "takeBit",
                            code: "takeBit",
                            type: .bool
                        ),
                        Symbol(
                            id: "drinkBit",
                            code: "drinkBit",
                            type: .bool
                        )
                    ]
                ),
                Symbol(
                    id: "action",
                    code: "action: waterFunc",
                    type: .routine,
                    children: [
                        Symbol(
                            id: "waterFunc",
                            code: "waterFunc",
                            type: .routine
                        )
                    ]
                ),
                Symbol(
                    id: "size",
                    code: "size: 4",
                    type: .int,
                    children: [
                        Symbol(
                            id: "4",
                            code: "4",
                            type: .int
                        )
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("water"), expected)
    }

    func testTroll() throws {
        let symbol = try factory.init([
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
        ]).process()

        let expected = Symbol(
            id: "troll",
            code: #"""
                /// The `troll` (TROLL) object.
                var troll = Object(
                    action: trollFunc,
                    adjectives: ["nasty"],
                    description: "troll",
                    flags: [
                        actorBit,
                        openBit,
                        trytakeBit
                    ],
                    location: trollRoom,
                    longDescription: """
                        A nasty-looking troll, brandishing a bloody axe, blocks all \
                        passages out of the room.
                        """,
                    strength: 2,
                    synonyms: ["troll"]
                )
                """#,
            type: .object,
            category: .objects,
            children: [
                Symbol(
                    id: "location",
                    code: "location: trollRoom",
                    type: .object,
                    children: [
                        Symbol(
                            id: "trollRoom",
                            code: "trollRoom",
                            type: .object
                        )
                    ]
                ),
                Symbol(
                    id: "synonyms",
                    code: "synonyms: [\"troll\"]",
                    type: .array(.string),
                    children: [
                        Symbol(
                            id: "troll",
                            code: "troll",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "adjectives",
                    code: "adjectives: [\"nasty\"]",
                    type: .array(.string),
                    children: [
                        Symbol(
                            id: "nasty",
                            code: "nasty",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "description",
                    code: "description: \"troll\"",
                    type: .string,
                    children: [
                        Symbol(
                            id: "\"troll\"",
                            code: "\"troll\"",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "flags",
                    code: """
                         flags: [
                             actorBit,
                             openBit,
                             trytakeBit
                         ]
                         """,
                    type: .array(.bool),
                    children: [
                        Symbol(
                            id: "actorBit",
                            code: "actorBit",
                            type: .bool
                        ),
                        Symbol(
                            id: "openBit",
                            code: "openBit",
                            type: .bool
                        ),
                        Symbol(
                            id: "trytakeBit",
                            code: "trytakeBit",
                            type: .bool
                        )
                    ]
                ),
                Symbol(
                    id: "action",
                    code: "action: trollFunc",
                    type: .routine,
                    children: [
                        Symbol(
                            id: "trollFunc",
                            code: "trollFunc",
                            type: .routine
                        )
                    ]
                ),
                Symbol(
                    id: "longDescription",
                    code: #"""
                         longDescription: """
                             A nasty-looking troll, brandishing a bloody axe, blocks all \
                             passages out of the room.
                             """
                         """#,
                    type: .string,
                    children: [
                        Symbol(
                            id: #"""
                             """
                                 A nasty-looking troll, brandishing a bloody axe, blocks all \
                                 passages out of the room.
                                 """
                             """#,
                            code: #"""
                             """
                                 A nasty-looking troll, brandishing a bloody axe, blocks all \
                                 passages out of the room.
                                 """
                             """#,
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "strength",
                    code: "strength: 2",
                    type: .int,
                    children: [
                        Symbol(
                            id: "2",
                            code: "2",
                            type: .int
                        )
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("troll"), expected)
    }

    func testAdvertisement() throws {
        let symbol = try factory.init([
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
        ]).process()

        XCTAssertNoDifference(symbol.code, #"""
            /// The `advertisement` (ADVERTISEMENT) object.
            var advertisement = Object(
                adjectives: ["small"],
                description: "leaflet",
                flags: [
                    readBit,
                    takeBit,
                    burnBit
                ],
                location: mailbox,
                longDescription: "A small leaflet is on the ground.",
                size: 2,
                synonyms: [
                    "advertisement",
                    "leaflet",
                    "booklet",
                    "mail"
                ],
                text: """
                    "WELCOME TO ZORK!
                    *
                    ZORK is a game of adventure, danger, and low cunning. In it \
                    you will explore some of the most amazing territory ever \
                    seen by mortals. No computer should be without one!"
                    """
            )
            """#.replacingOccurrences(of: "*", with: "")
        )
    }

    func testTrophyCase() throws {
        let symbol = try factory.init([
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
        ]).process()

        XCTAssertNoDifference(symbol.code, """
            /// The `trophyCase` (TROPHY-CASE) object.
            var trophyCase = Object(
                action: trophyCaseFunc,
                adjectives: ["trophy"],
                capacity: 10000,
                description: "trophy case",
                flags: [
                    transBit,
                    contBit,
                    ndescBit,
                    trytakeBit,
                    searchBit
                ],
                location: livingRoom,
                synonyms: ["case"]
            )
            """
        )
    }

    func testGlobalObjects() throws {
        let symbol = try factory.init([
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
        ]).process()

        let expected = Symbol(
            id: "globalObjects",
            code: """
                /// The `globalObjects` (GLOBAL-OBJECTS) object.
                var globalObjects = Object(
                    flags: [
                        rmungBit,
                        invisible,
                        touchBit,
                        surfaceBit,
                        trytakeBit,
                        openBit,
                        searchBit,
                        transBit,
                        onBit,
                        rlandBit,
                        fightBit,
                        staggered,
                        wearBit
                    ]
                )
                """,
            type: .object,
            category: .objects,
            children: [
                Symbol(
                    id: "flags",
                    code: """
                         flags: [
                             rmungBit,
                             invisible,
                             touchBit,
                             surfaceBit,
                             trytakeBit,
                             openBit,
                             searchBit,
                             transBit,
                             onBit,
                             rlandBit,
                             fightBit,
                             staggered,
                             wearBit
                         ]
                         """,
                    type: .array(.bool),
                    children: [
                        Symbol("rmungBit", type: .bool),
                        Symbol("invisible", type: .bool),
                        Symbol("touchBit", type: .bool),
                        Symbol("surfaceBit", type: .bool),
                        Symbol("trytakeBit", type: .bool),
                        Symbol("openBit", type: .bool),
                        Symbol("searchBit", type: .bool),
                        Symbol("transBit", type: .bool),
                        Symbol("onBit", type: .bool),
                        Symbol("rlandBit", type: .bool),
                        Symbol("fightBit", type: .bool),
                        Symbol("staggered", type: .bool),
                        Symbol("wearBit", type: .bool)
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("globalObjects"), expected)
    }

    func testLocalGlobals() throws {
        let symbol = try factory.init([
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
        ]).process()

        let expected = Symbol(
            id: "localGlobals",
            code: """
                /// The `localGlobals` (LOCAL-GLOBALS) object.
                var localGlobals = Object(
                    advfcn: 0,
                    capacity: 0,
                    contfcn: 0,
                    descriptionFunction: pathObject,
                    firstDescription: "F",
                    globals: [globalObjects],
                    location: globalObjects,
                    longDescription: "F",
                    size: 0,
                    synonyms: ["zzmgck"],
                    things: [
                        Thing(
                            adjectives: [],
                            nouns: ["foobar"],
                            action: vWalk
                        )
                    ],
                    vehicleType: true
                )
                """,
            type: .object,
            category: .objects,
            children: [
                Symbol(
                    id: "location",
                    code: "location: globalObjects",
                    type: .object,
                    children: [
                        Symbol(
                            id: "globalObjects",
                            code: "globalObjects",
                            type: .object
                        )
                    ]
                ),
                Symbol(
                    id: "synonyms",
                    code: "synonyms: [\"zzmgck\"]",
                    type: .array(.string),
                    children: [
                        Symbol(
                            id: "zzmgck",
                            code: "zzmgck",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "descriptionFunction",
                    code: "descriptionFunction: pathObject",
                    type: .routine,
                    children: [
                        Symbol(
                            id: "pathObject",
                            code: "pathObject",
                            type: .routine
                        )
                    ]
                ),
                Symbol(
                    id: "globals",
                    code: "globals: [globalObjects]",
                    type: .array(.object),
                    children: [
                        Symbol(
                            id: "globalObjects",
                            code: "globalObjects",
                            type: .object
                        )
                    ]
                ),
                Symbol(
                    id: "advfcn",
                    code: "advfcn: 0",
                    type: .int,
                    children: [
                        Symbol(
                            id: "0",
                            code: "0",
                            type: .int
                        )
                    ]
                ),
                Symbol(
                    id: "firstDescription",
                    code: "firstDescription: \"F\"",
                    type: .string,
                    children: [
                        Symbol(
                            id: "\"F\"",
                            code: "\"F\"",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "longDescription",
                    code: "longDescription: \"F\"",
                    type: .string,
                    children: [
                        Symbol(
                            id: "\"F\"",
                            code: "\"F\"",
                            type: .string
                        )
                    ]
                ),
                Symbol(
                    id: "things",
                    code: """
                         things: [
                             Thing(
                                 adjectives: [],
                                 nouns: ["foobar"],
                                 action: vWalk
                             )
                         ]
                         """,
                    type: .array(.thing),
                    children: [
                        Symbol(
                            id: "thing",
                            code: """
                             Thing(
                                 adjectives: [],
                                 nouns: ["foobar"],
                                 action: vWalk
                             )
                             """,
                            type: .thing
                        )
                    ]
                ),
                Symbol(
                    id: "contfcn",
                    code: "contfcn: 0",
                    type: .int,
                    children: [
                        Symbol(
                            id: "0",
                            code: "0",
                            type: .int
                        )
                    ]
                ),
                Symbol(
                    id: "vehicleType",
                    code: "vehicleType: true",
                    type: .bool,
                    children: [
                        Symbol(
                            id: "true",
                            code: "true",
                            type: .bool
                        )
                    ]
                ),
                Symbol(
                    id: "size",
                    code: "size: 0",
                    type: .int,
                    children: [
                        Symbol(
                            id: "0",
                            code: "0",
                            type: .int
                        )
                    ]
                ),
                Symbol(
                    id: "capacity",
                    code: "capacity: 0",
                    type: .int,
                    children: [
                        Symbol(
                            id: "0",
                            code: "0",
                            type: .int
                        )
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("localGlobals"), expected)
    }

    func testAdventurer() throws {
        let symbol = try factory.init([
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
        ]).process()

        XCTAssertNoDifference(symbol.code, """
            /// The `adventurer` (ADVENTURER) object.
            var adventurer = Object(
                action: 0,
                description: "cretin",
                flags: [
                    ndescBit,
                    invisible,
                    sacredBit,
                    actorBit
                ],
                strength: 0,
                synonyms: ["adventurer"]
            )
            """
        )
    }
}
