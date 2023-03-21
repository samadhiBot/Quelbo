//
//  RoomTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/17/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RoomTests: QuelboTests {
    let factory = Factories.Room.self

    override func setUp() {
        super.setUp()

        process("""
            <DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ROOM"))
    }

    func testWestOfHouse() throws {
        let symbol = process("""
            <ROOM WEST-OF-HOUSE
                  (IN ROOMS)
                  (DESC "West of House")
                  (NORTH TO NORTH-OF-HOUSE)
                  (SOUTH TO SOUTH-OF-HOUSE)
                  (NE TO NORTH-OF-HOUSE)
                  (SE TO SOUTH-OF-HOUSE)
                  (WEST TO FOREST-1)
                  (EAST "The door is boarded and you can't remove the boards.")
                  (SW TO STONE-BARROW IF WON-FLAG)
                  (IN TO STONE-BARROW IF WON-FLAG)
                  (ACTION WEST-HOUSE)
                  (FLAGS RLANDBIT ONBIT SACREDBIT)
                  (GLOBAL WHITE-HOUSE BOARD FOREST)>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "westOfHouse",
            code: """
                /// The `westOfHouse` (WEST-OF-HOUSE) room.
                var westOfHouse = Room(
                    id: "westOfHouse",
                    action: "westHouse",
                    description: "West of House",
                    directions: [
                        .north: .to("northOfHouse"),
                        .south: .to("southOfHouse"),
                        .northEast: .to("northOfHouse"),
                        .southEast: .to("southOfHouse"),
                        .west: .to("forest1"),
                        .east: .blocked("The door is boarded and you can't remove the boards."),
                        .southWest: .conditional("stoneBarrow", if: "wonFlag"),
                        .in: .conditional("stoneBarrow", if: "wonFlag"),
                    ],
                    flags: [.isDryLand, .isOn, .isSacred],
                    globals: ["whiteHouse", "board", "forest"],
                    location: "rooms"
                )
                """,
            type: .object,
            category: .rooms,
            isCommittable: true
        ))
    }

    func testReservoirSouth() throws {
        let symbol = process("""
            <ROOM RESERVOIR-SOUTH
                  (IN ROOMS)
                  (DESC "Reservoir South")
                  (SE TO DEEP-CANYON)
                  (SW TO CHASM-ROOM)
                  (EAST TO DAM-ROOM)
                  (WEST TO STREAM-VIEW)
                  (NORTH TO RESERVOIR
                   IF LOW-TIDE ELSE "You would drown.")
                  (ACTION RESERVOIR-SOUTH-FCN)
                  (FLAGS RLANDBIT)
                  (GLOBAL GLOBAL-WATER)
                  (PSEUDO "LAKE" LAKE-PSEUDO "CHASM" CHASM-PSEUDO)>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "reservoirSouth",
            code: """
            /// The `reservoirSouth` (RESERVOIR-SOUTH) room.
            var reservoirSouth = Room(
                id: "reservoirSouth",
                action: "reservoirSouthFunc",
                description: "Reservoir South",
                directions: [
                    .southEast: .to("deepCanyon"),
                    .southWest: .to("chasmRoom"),
                    .east: .to("damRoom"),
                    .west: .to("streamView"),
                    .north: .conditionalElse("reservoir",
                        if: "lowTide",
                        else: "You would drown."
                    ),
                ],
                flags: [.isDryLand],
                globals: ["globalWater"],
                location: "rooms",
                things: [
                    Thing(
                        action: "lakePseudo",
                        adjectives: [],
                        nouns: ["lake"]
                    ),
                    Thing(
                        action: "chasmPseudo",
                        adjectives: [],
                        nouns: ["chasm"]
                    ),
                ]
            )
            """,
            type: .object,
            category: .rooms,
            isCommittable: true
        ))
    }

    func testEastOfHouse() throws {
        let symbol = process("""
            <OBJECT KITCHEN-WINDOW>

            <ROOM CLEARING>
            <ROOM KITCHEN>
            <ROOM NORTH-OF-HOUSE>
            <ROOM NORTH-OF-HOUSE>
            <ROOM SOUTH-OF-HOUSE>
            <ROOM SOUTH-OF-HOUSE>

            <ROOM EAST-OF-HOUSE
                  (IN ROOMS)
                  (DESC "Behind House")
                  (NORTH TO NORTH-OF-HOUSE)
                  (SOUTH TO SOUTH-OF-HOUSE)
                  (SW TO SOUTH-OF-HOUSE)
                  (NW TO NORTH-OF-HOUSE)
                  (EAST TO CLEARING)
                  (WEST TO KITCHEN IF KITCHEN-WINDOW IS OPEN)
                  (IN TO KITCHEN IF KITCHEN-WINDOW IS OPEN)
                  (ACTION EAST-HOUSE)
                  (FLAGS RLANDBIT ONBIT SACREDBIT)
                  (GLOBAL WHITE-HOUSE KITCHEN-WINDOW FOREST)>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "eastOfHouse",
            code: """
            /// The `eastOfHouse` (EAST-OF-HOUSE) room.
            var eastOfHouse = Room(
                id: "eastOfHouse",
                action: "eastHouse",
                description: "Behind House",
                directions: [
                    .north: .to("northOfHouse"),
                    .south: .to("southOfHouse"),
                    .southWest: .to("southOfHouse"),
                    .northWest: .to("northOfHouse"),
                    .east: .to("clearing"),
                    .west: .conditional("kitchen", if: "Objects.kitchenWindow.isOpen"),
                    .in: .conditional("kitchen", if: "Objects.kitchenWindow.isOpen"),
                ],
                flags: [.isDryLand, .isOn, .isSacred],
                globals: ["whiteHouse", "kitchenWindow", "forest"],
                location: "rooms"
            )
            """,
            type: .object,
            category: .rooms,
            isCommittable: true
        ))
    }

    func testStudio() throws {
        let symbol = process("""
            <ROOM STUDIO
                  (IN ROOMS)
                  (LDESC
            "This appears to have been an artist's studio. The walls and floors are
            splattered with paints of 69 different colors. Strangely enough, nothing
            of value is hanging here. At the south end of the room is an open door
            (also covered with paint). A dark and narrow chimney leads up from a
            fireplace; although you might be able to get up it, it seems unlikely
            you could get back down.")
                  (DESC "Studio")
                  (SOUTH TO GALLERY)
                  (UP PER UP-CHIMNEY-FUNCTION)
                  (FLAGS RLANDBIT)
                  (GLOBAL CHIMNEY)
                  (PSEUDO "DOOR" DOOR-PSEUDO "PAINT" PAINT-PSEUDO)>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "studio",
            code: #"""
            /// The `studio` (STUDIO) room.
            var studio = Room(
                id: "studio",
                description: "Studio",
                directions: [
                    .south: .to("gallery"),
                    .up: .per("upChimneyFunc"),
                ],
                flags: [.isDryLand],
                globals: ["chimney"],
                location: "rooms",
                longDescription: """
                    This appears to have been an artist's studio. The walls and \
                    floors are splattered with paints of 69 different colors. \
                    Strangely enough, nothing of value is hanging here. At the \
                    south end of the room is an open door (also covered with \
                    paint). A dark and narrow chimney leads up from a fireplace; \
                    although you might be able to get up it, it seems unlikely \
                    you could get back down.
                    """,
                things: [
                    Thing(
                        action: "doorPseudo",
                        adjectives: [],
                        nouns: ["door"]
                    ),
                    Thing(
                        action: "paintPseudo",
                        adjectives: [],
                        nouns: ["paint"]
                    ),
                ]
            )
            """#,
            type: .object,
            category: .rooms,
            isCommittable: true
        ))
    }

    func testFoyer() throws {
        let symbol = process("""
            <ROOM FOYER
                (DESC "Foyer of the Opera House")
                (IN ROOMS)
                (LDESC "You are standing in a spacious hall, splendidly decorated in red
            and gold, with glittering chandeliers overhead. The entrance from
            the street is to the north, and there are doorways south and west.")
                (SOUTH TO BAR)
                (WEST TO CLOAKROOM)
                (NORTH SORRY "You've only just arrived, and besides, the weather outside
            seems to be getting worse.")
                (FLAGS LIGHTBIT)>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "foyer",
            code: #"""
            /// The `foyer` (FOYER) room.
            var foyer = Room(
                id: "foyer",
                description: "Foyer of the Opera House",
                directions: [
                    .south: .to("bar"),
                    .west: .to("cloakroom"),
                    .north: .blocked("""
                        You've only just arrived, and besides, the weather outside \
                        seems to be getting worse.
                        """),
                ],
                flags: [.isLight],
                location: "rooms",
                longDescription: """
                    You are standing in a spacious hall, splendidly decorated in \
                    red and gold, with glittering chandeliers overhead. The \
                    entrance from the street is to the north, and there are \
                    doorways south and west.
                    """
            )
            """#,
            type: .object,
            category: .rooms,
            isCommittable: true
        ))
    }

    func testInStream() throws {
        process("<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>")

        let symbol = process("""
            <ROOM IN-STREAM
                  (IN ROOMS)
                  (LDESC
                      "You are on the gently flowing stream. The upstream route is too narrow
                      to navigate, and the downstream route is invisible due to twisting
                      walls. There is a narrow beach to land on.")
                  (DESC "Stream")
                  (UP "The channel is too narrow.")
                  (WEST "The channel is too narrow.")
                  (LAND TO STREAM-VIEW)
                  (DOWN TO RESERVOIR)
                  (EAST TO RESERVOIR)
                  (FLAGS NONLANDBIT )
                  (GLOBAL GLOBAL-WATER)
                  (PSEUDO "STREAM" STREAM-PSEUDO)>
        """)

        let expected = Statement(
            id: "inStream",
            code: #"""
            /// The `inStream` (IN-STREAM) room.
            var inStream = Room(
                id: "inStream",
                description: "Stream",
                directions: [
                    .up: .blocked("The channel is too narrow."),
                    .west: .blocked("The channel is too narrow."),
                    .land: .to("streamView"),
                    .down: .to("reservoir"),
                    .east: .to("reservoir"),
                ],
                flags: [.isNotLand],
                globals: ["globalWater"],
                location: "rooms",
                longDescription: """
                    You are on the gently flowing stream. The upstream route is \
                    too narrow to navigate, and the downstream route is \
                    invisible due to twisting walls. There is a narrow beach to \
                    land on.
                    """,
                things: [
                    Thing(
                        action: "streamPseudo",
                        adjectives: [],
                        nouns: ["stream"]
                    ),
                ]
            )
            """#,
            type: .object,
            category: .rooms,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.rooms.find("inStream"), expected)
    }
}
