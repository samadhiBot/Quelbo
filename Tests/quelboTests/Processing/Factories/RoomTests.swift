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
                    action: westHouse,
                    description: "West of House",
                    directions: [
                        .north: .to("northOfHouse"),
                        .south: .to("southOfHouse"),
                        .northEast: .to("northOfHouse"),
                        .southEast: .to("southOfHouse"),
                        .west: .to("forest1"),
                        .east: .blocked("The door is boarded and you can't remove the boards."),
                        .southWest: .conditional("stoneBarrow", if: Global.wonFlag),
                        .in: .conditional("stoneBarrow", if: Global.wonFlag),
                    ],
                    flags: [
                        .isDryLand,
                        .isOn,
                        .isSacred,
                    ],
                    globals: [
                        whiteHouse,
                        board,
                        forest,
                    ],
                    location: rooms
                )
                """,
            type: .object,
            category: .rooms,
            isCommittable: true
        ))
    }

    func testReservoirSouth() throws {
        let symbol = try factory.init([
            .atom("RESERVOIR-SOUTH"),
            .list([
                .atom("IN"),
                .atom("ROOMS")
            ]),
            .list([
                .atom("DESC"),
                .string("Reservoir South")
            ]),
            .list([
                .atom("SE"),
                .atom("TO"),
                .atom("DEEP-CANYON")
            ]),
            .list([
                .atom("SW"),
                .atom("TO"),
                .atom("CHASM-ROOM")
            ]),
            .list([
                .atom("EAST"),
                .atom("TO"),
                .atom("DAM-ROOM")
            ]),
            .list([
                .atom("WEST"),
                .atom("TO"),
                .atom("STREAM-VIEW")
            ]),
            .list([
                .atom("NORTH"),
                .atom("TO"),
                .atom("RESERVOIR"),
                .atom("IF"),
                .atom("LOW-TIDE"),
                .atom("ELSE"),
                .string("You would drown.")
            ]),
            .list([
                .atom("ACTION"),
                .atom("RESERVOIR-SOUTH-FCN")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("RLANDBIT")
            ]),
            .list([
                .atom("GLOBAL"),
                .atom("GLOBAL-WATER")
            ]),
            .list([
                .atom("PSEUDO"),
                .string("LAKE"),
                .atom("LAKE-PSEUDO"),
                .string("CHASM"),
                .atom("CHASM-PSEUDO")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "reservoirSouth",
            code: """
            /// The `reservoirSouth` (RESERVOIR-SOUTH) room.
            var reservoirSouth = Room(
                id: "reservoirSouth",
                action: reservoirSouthFunc,
                description: "Reservoir South",
                directions: [
                    .southEast: .to("deepCanyon"),
                    .southWest: .to("chasmRoom"),
                    .east: .to("damRoom"),
                    .west: .to("streamView"),
                    .north: .conditionalElse("reservoir",
                        if: Global.lowTide,
                        else: "You would drown."
                    ),
                ],
                flags: [.isDryLand],
                globals: [globalWater],
                location: rooms,
                things: [
                    Thing(
                        action: lakePseudo,
                        adjectives: [],
                        nouns: ["lake"]
                    ),
                    Thing(
                        action: chasmPseudo,
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
        let symbol = try factory.init([
            .atom("EAST-OF-HOUSE"),
            .list([
                .atom("IN"),
                .atom("ROOMS")
            ]),
            .list([
                .atom("DESC"),
                .string("Behind House")
            ]),
            .list([
                .atom("NORTH"),
                .atom("TO"),
                .atom("NORTH-OF-HOUSE")
            ]),
            .list([
                .atom("SOUTH"),
                .atom("TO"),
                .atom("SOUTH-OF-HOUSE")
            ]),
            .list([
                .atom("SW"),
                .atom("TO"),
                .atom("SOUTH-OF-HOUSE")
            ]),
            .list([
                .atom("NW"),
                .atom("TO"),
                .atom("NORTH-OF-HOUSE")
            ]),
            .list([
                .atom("EAST"),
                .atom("TO"),
                .atom("CLEARING")
            ]),
            .list([
                .atom("WEST"),
                .atom("TO"),
                .atom("KITCHEN"),
                .atom("IF"),
                .atom("KITCHEN-WINDOW"),
                .atom("IS"),
                .atom("OPEN")
            ]),
            .list([
                .atom("IN"),
                .atom("TO"),
                .atom("KITCHEN"),
                .atom("IF"),
                .atom("KITCHEN-WINDOW"),
                .atom("IS"),
                .atom("OPEN")
            ]),
            .list([
                .atom("ACTION"),
                .atom("EAST-HOUSE")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("RLANDBIT"),
                .atom("ONBIT"),
                .atom("SACREDBIT")
            ]),
            .list([
                .atom("GLOBAL"),
                .atom("WHITE-HOUSE"),
                .atom("KITCHEN-WINDOW"),
                .atom("FOREST")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "eastOfHouse",
            code: """
            /// The `eastOfHouse` (EAST-OF-HOUSE) room.
            var eastOfHouse = Room(
                id: "eastOfHouse",
                action: eastHouse,
                description: "Behind House",
                directions: [
                    .north: .to("northOfHouse"),
                    .south: .to("southOfHouse"),
                    .southWest: .to("southOfHouse"),
                    .northWest: .to("northOfHouse"),
                    .east: .to("clearing"),
                    .west: .conditional("kitchen", if: Object.kitchenWindow.isOpen),
                    .in: .conditional("kitchen", if: Object.kitchenWindow.isOpen),
                ],
                flags: [
                    .isDryLand,
                    .isOn,
                    .isSacred,
                ],
                globals: [
                    Object.whiteHouse,
                    Object.kitchenWindow,
                    Object.forest,
                ],
                location: rooms
            )
            """,
            type: .object,
            category: .rooms,
            isCommittable: true
        ))
    }

    func testStudio() throws {
        let symbol = try factory.init([
            .atom("STUDIO"),
            .list([
                .atom("IN"),
                .atom("ROOMS")
            ]),
            .list([
                .atom("LDESC"),
                .string("""
                    This appears to have been an artist's studio. The walls and floors are \
                    splattered with paints of 69 different colors. Strangely enough, nothing \
                    of value is hanging here. At the south end of the room is an open door \
                    (also covered with paint). A dark and narrow chimney leads up from a \
                    fireplace; although you might be able to get up it, it seems unlikely \
                    you could get back down.
                    """)
            ]),
            .list([
                .atom("DESC"),
                .string("Studio")
            ]),
            .list([
                .atom("SOUTH"),
                .atom("TO"),
                .atom("GALLERY")
            ]),
            .list([
                .atom("UP"),
                .atom("PER"),
                .atom("UP-CHIMNEY-FUNCTION")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("RLANDBIT")
            ]),
            .list([
                .atom("GLOBAL"),
                .atom("CHIMNEY")
            ]),
            .list([
                .atom("PSEUDO"),
                .string("DOOR"),
                .atom("DOOR-PSEUDO"),
                .string("PAINT"),
                .atom("PAINT-PSEUDO")
            ])
        ], with: &localVariables).process()

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
                globals: [chimney],
                location: rooms,
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
                        action: doorPseudo,
                        adjectives: [],
                        nouns: ["door"]
                    ),
                    Thing(
                        action: paintPseudo,
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
        let symbol = try factory.init([
            .atom("FOYER"),
            .list([
                .atom("DESC"),
                .string("Foyer of the Opera House")
            ]),
            .list([
                .atom("IN"),
                .atom("ROOMS")
            ]),
            .list([
                .atom("LDESC"),
                .string("You are standing in a spacious hall, splendidly decorated in red and gold, with glittering chandeliers overhead. The entrance from the street is to the north, and there are doorways south and west.")
            ]),
            .list([
                .atom("SOUTH"),
                .atom("TO"),
                .atom("BAR")
            ]),
            .list([
                .atom("WEST"),
                .atom("TO"),
                .atom("CLOAKROOM")
            ]),
            .list([
                .atom("NORTH"),
                .atom("SORRY"),
                .string("You\'ve only just arrived, and besides, the weather outside seems to be getting worse.")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("LIGHTBIT")
            ])
        ], with: &localVariables).process()

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
                location: rooms,
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
                globals: [globalWater],
                location: rooms,
                longDescription: """
                    You are on the gently flowing stream. The upstream route is \
                    too narrow to navigate, and the downstream route is \
                    invisible due to twisting walls. There is a narrow beach to \
                    land on.
                    """,
                things: [
                    Thing(
                        action: streamPseudo,
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
