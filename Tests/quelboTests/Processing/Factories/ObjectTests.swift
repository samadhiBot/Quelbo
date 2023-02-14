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
        AssertSameFactory(factory, Game.findFactory("OBJECT"))
    }

    func testWhiteHouse() throws {
        process("<OBJECT LOCAL-GLOBALS>")

        let symbol = process("""
            <OBJECT WHITE-HOUSE
                (IN LOCAL-GLOBALS)
                (SYNONYM HOUSE)
                (ADJECTIVE WHITE BEAUTI COLONI)
                (DESC "white house")
                (FLAGS NDESCBIT)
                (ACTION WHITE-HOUSE-F)>
        """)

        let expected = Statement(
            id: "whiteHouse",
            code: """
                /// The `whiteHouse` (WHITE-HOUSE) object.
                var whiteHouse = Object(
                    id: "whiteHouse",
                    action: whiteHouseFunc,
                    adjectives: [
                        "white",
                        "beauti",
                        "coloni",
                    ],
                    description: "white house",
                    flags: [.omitDescription],
                    location: localGlobals,
                    synonyms: ["house"]
                )
                """,
            type: .object,
            category: .objects,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.objects.find("whiteHouse"), expected)
    }

    func testBrokenEgg() throws {
        let symbol = process("""
            <OBJECT BROKEN-EGG
                (SYNONYM EGG TREASURE)
                (ADJECTIVE BROKEN BIRDS ENCRUSTED JEWEL)
                (DESC "broken jewel-encrusted egg")
                (FLAGS TAKEBIT CONTBIT OPENBIT)
                (CAPACITY 6)
                (TVALUE 2)
                (LDESC "There is a somewhat ruined egg here.")>
        """)

        let expected = Statement(
            id: "brokenEgg",
            code: """
                /// The `brokenEgg` (BROKEN-EGG) object.
                var brokenEgg = Object(
                    id: "brokenEgg",
                    adjectives: [
                        "broken",
                        "birds",
                        "encrusted",
                        "jewel",
                    ],
                    capacity: 6,
                    description: "broken jewel-encrusted egg",
                    flags: [
                        .isContainer,
                        .isOpen,
                        .isTakable,
                    ],
                    longDescription: "There is a somewhat ruined egg here.",
                    synonyms: ["egg", "treasure"],
                    takeValue: 2
                )
                """,
            type: .object,
            category: .objects,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.objects.find("brokenEgg"), expected)
    }

    func testBat() throws {
        let symbol = process("""
            <OBJECT BAT
                (IN BAT-ROOM)
                (SYNONYM BAT VAMPIRE)
                (ADJECTIVE VAMPIRE DERANGED)
                (DESC "bat")
                (FLAGS ACTORBIT TRYTAKEBIT)
                (DESCFCN BAT-D)
                (ACTION BAT-F)>
        """)

        let expected = Statement(
            id: "bat",
            code: """
                /// The `bat` (BAT) object.
                var bat = Object(
                    id: "bat",
                    action: batFunc,
                    adjectives: ["vampire", "deranged"],
                    description: "bat",
                    descriptionFunction: batD,
                    flags: [
                        .isActor,
                        .noImplicitTake,
                    ],
                    location: batRoom,
                    synonyms: ["bat", "vampire"]
                )
                """,
            type: .object,
            category: .objects,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.objects.find("bat"), expected)
    }

    func testSkull() throws {
        let symbol = process("""
            <OBJECT SKULL
                (IN LAND-OF-LIVING-DEAD)
                (SYNONYM SKULL HEAD TREASURE)
                (ADJECTIVE CRYSTAL)
                (DESC "crystal skull")
                (FDESC
                    "Lying in one corner of the room is a beautifully carved crystal skull.
                    It appears to be grinning at you rather nastily.")
                (FLAGS TAKEBIT)
                (VALUE 10)
                (TVALUE 10)>
        """)

        let expected = Statement(
            id: "skull",
            code: #"""
                /// The `skull` (SKULL) object.
                var skull = Object(
                    id: "skull",
                    adjectives: ["crystal"],
                    description: "crystal skull",
                    firstDescription: """
                        Lying in one corner of the room is a beautifully carved \
                        crystal skull. It appears to be grinning at you rather \
                        nastily.
                        """,
                    flags: [.isTakable],
                    location: landOfLivingDead,
                    synonyms: [
                        "skull",
                        "head",
                        "treasure",
                    ],
                    takeValue: 10,
                    value: 10
                )
                """#,
            type: .object,
            category: .objects,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.objects.find("skull"), expected)
    }

    func testWater() throws {
        let symbol = process("""
            <OBJECT WATER
                (IN BOTTLE)
                (SYNONYM WATER QUANTITY LIQUID H2O)
                (DESC "quantity of water")
                (FLAGS TRYTAKEBIT TAKEBIT DRINKBIT)
                (ACTION WATER-F)
                (SIZE 4)>
        """)

        let expected = Statement(
            id: "water",
            code: """
                /// The `water` (WATER) object.
                var water = Object(
                    id: "water",
                    action: waterFunc,
                    description: "quantity of water",
                    flags: [
                        .isDrinkable,
                        .isTakable,
                        .noImplicitTake,
                    ],
                    location: bottle,
                    size: 4,
                    synonyms: [
                        "water",
                        "quantity",
                        "liquid",
                        "h2o",
                    ]
                )
                """,
            type: .object,
            category: .objects,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.objects.find("water"), expected)
    }

    func testTroll() throws {
        let symbol = process("""
            <OBJECT TROLL
                (IN TROLL-ROOM)
                (SYNONYM TROLL)
                (ADJECTIVE NASTY)
                (DESC "troll")
                (FLAGS ACTORBIT OPENBIT TRYTAKEBIT)
                (ACTION TROLL-FCN)
                (LDESC
                    "A nasty-looking troll, brandishing a bloody axe, blocks all passages
                    out of the room.")
                (STRENGTH 2)>
        """)

        let expected = Statement(
            id: "troll",
            code: #"""
                /// The `troll` (TROLL) object.
                var troll = Object(
                    id: "troll",
                    action: trollFunc,
                    adjectives: ["nasty"],
                    description: "troll",
                    flags: [
                        .isActor,
                        .isOpen,
                        .noImplicitTake,
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
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.objects.find("troll"), expected)
    }

    func testAdvertisement() throws {
        let symbol = process(#"""
            <OBJECT ADVERTISEMENT
                (IN MAILBOX)
                (SYNONYM ADVERTISEMENT LEAFLET BOOKLET MAIL)
                (ADJECTIVE SMALL)
                (DESC "leaflet")
                (FLAGS READBIT TAKEBIT BURNBIT)
                (LDESC "A small leaflet is on the ground.")
                (TEXT
                    "\"WELCOME TO ZORK!|
                    |
                    ZORK is a game of adventure, danger, and low cunning. In it you
                    will explore some of the most amazing territory ever seen by mortals.
                    No computer should be without one!\"")
                (SIZE 2)>
        """#)

        XCTAssertNoDifference(symbol, .statement(
            id: "advertisement",
            code: #"""
                /// The `advertisement` (ADVERTISEMENT) object.
                var advertisement = Object(
                    id: "advertisement",
                    adjectives: ["small"],
                    description: "leaflet",
                    flags: [
                        .isBurnable,
                        .isReadable,
                        .isTakable,
                    ],
                    location: mailbox,
                    longDescription: "A small leaflet is on the ground.",
                    size: 2,
                    synonyms: [
                        "advertisement",
                        "leaflet",
                        "booklet",
                        "mail",
                    ],
                    text: """
                        "WELCOME TO ZORK!

                        ZORK is a game of adventure, danger, and low cunning. In it \
                        you will explore some of the most amazing territory ever \
                        seen by mortals. No computer should be without one!"
                        """
                )
                """#,
            type: .object,
            category: .objects,
            isCommittable: true
        ))
    }

    func testTrophyCase() throws {
        let symbol = process("""
            <OBJECT TROPHY-CASE    ;"first obj so L.R. desc looks right."
                (IN LIVING-ROOM)
                (SYNONYM CASE)
                (ADJECTIVE TROPHY)
                (DESC "trophy case")
                (FLAGS TRANSBIT CONTBIT NDESCBIT TRYTAKEBIT SEARCHBIT)
                (ACTION TROPHY-CASE-FCN)
                (CAPACITY 10000)>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "trophyCase",
            code: """
                /// The `trophyCase` (TROPHY-CASE) object.
                var trophyCase = Object(
                    id: "trophyCase",
                    action: trophyCaseFunc,
                    adjectives: ["trophy"],
                    capacity: 10000,
                    description: "trophy case",
                    flags: [
                        .isContainer,
                        .isSearchable,
                        .isTransparent,
                        .noImplicitTake,
                        .omitDescription,
                    ],
                    location: livingRoom,
                    synonyms: ["case"]
                )
                """,
            type: .object,
            category: .objects,
            isCommittable: true
        ))
    }

    func testGlobalObjects() throws {
        let symbol = process("""
            <OBJECT GLOBAL-OBJECTS
                (FLAGS RMUNGBIT INVISIBLE TOUCHBIT SURFACEBIT TRYTAKEBIT OPENBIT SEARCHBIT
                 TRANSBIT ONBIT RLANDBIT FIGHTBIT STAGGERED WEARBIT)>
        """)

        let expected = Statement(
            id: "globalObjects",
            code: """
                /// The `globalObjects` (GLOBAL-OBJECTS) object.
                var globalObjects = Object(
                    id: "globalObjects",
                    flags: [
                        .hasBeenTouched,
                        .isDestroyed,
                        .isDryLand,
                        .isFightable,
                        .isInvisible,
                        .isOn,
                        .isOpen,
                        .isSearchable,
                        .isStaggered,
                        .isSurface,
                        .isTransparent,
                        .isWearable,
                        .noImplicitTake,
                    ]
                )
                """,
            type: .object,
            category: .objects,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.objects.find("globalObjects"), expected)
    }

    func testLocalGlobals() throws {
        let symbol = process("""
            <OBJECT LOCAL-GLOBALS
                (IN GLOBAL-OBJECTS)
                (SYNONYM ZZMGCK)
                (DESCFCN PATH-OBJECT)
                (GLOBAL GLOBAL-OBJECTS)
                (ADVFCN 0)
                (FDESC "F")
                (LDESC "F")
                (PSEUDO "FOOBAR" V-WALK)
                (CONTFCN 0)
                (VTYPE 1)
                (SIZE 0)
                (CAPACITY 0)>
        """)

        let expected = Statement(
            id: "localGlobals",
            code: """
                /// The `localGlobals` (LOCAL-GLOBALS) object.
                var localGlobals = Object(
                    id: "localGlobals",
                    adventurerFunction: nil,
                    capacity: 0,
                    containerFunction: nil,
                    descriptionFunction: pathObject,
                    firstDescription: "F",
                    globals: [globalObjects],
                    location: globalObjects,
                    longDescription: "F",
                    size: 0,
                    synonyms: ["zzmgck"],
                    things: [
                        Thing(
                            action: vWalk,
                            adjectives: [],
                            nouns: ["foobar"]
                        ),
                    ],
                    vehicleType: true
                )
                """,
            type: .object,
            category: .objects,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.objects.find("localGlobals"), expected)
    }

    func testAdventurer() throws {
        let symbol = process("""
            <OBJECT ADVENTURER
                (SYNONYM ADVENTURER)
                (DESC "cretin")
                (FLAGS NDESCBIT INVISIBLE SACREDBIT ACTORBIT)
                (STRENGTH 0)
                (ACTION 0)>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "adventurer",
            code: """
                /// The `adventurer` (ADVENTURER) object.
                var adventurer = Object(
                    id: "adventurer",
                    action: nil,
                    description: "cretin",
                    flags: [
                        .isActor,
                        .isInvisible,
                        .isSacred,
                        .omitDescription,
                    ],
                    strength: 0,
                    synonyms: ["adventurer"]
                )
                """,
            type: .object,
            category: .objects,
            isCommittable: true
        ))
    }
}
