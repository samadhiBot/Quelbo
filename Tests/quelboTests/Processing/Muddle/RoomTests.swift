//
//  RoomTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/18/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RoomTests: XCTestCase {
    func testWhiteHouse() throws {
        var room = Object(.room, [
            .atom("WEST-OF-HOUSE"),
            .list([
                .atom("IN"),
                .atom("ROOMS")
            ]),
            .list([
                .atom("DESC"),
                .string("West of House")
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
                .atom("NE"),
                .atom("TO"),
                .atom("NORTH-OF-HOUSE")
            ]),
            .list([
                .atom("SE"),
                .atom("TO"),
                .atom("SOUTH-OF-HOUSE")
            ]),
            .list([
                .atom("WEST"),
                .atom("TO"),
                .atom("FOREST-1")
            ]),
            .list([
                .atom("EAST"),
                .string("The door is boarded and you can't remove the boards.")
            ]),
            .list([
                .atom("SW"),
                .atom("TO"),
                .atom("STONE-BARROW"),
                .atom("IF"),
                .atom("WON-FLAG")
            ]),
            .list([
                .atom("IN"),
                .atom("TO"),
                .atom("STONE-BARROW"),
                .atom("IF"),
                .atom("WON-FLAG")
            ]),
            .list([
                .atom("ACTION"),
                .atom("WEST-HOUSE")
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
                .atom("BOARD"),
                .atom("FOREST")
            ])
        ])

        XCTAssertNoDifference(try room.process(), .init(
            name: "westOfHouse",
            code: """
                /// The `westOfHouse` (WEST-OF-HOUSE) room.
                var westOfHouse = Room(
                    name: "westOfHouse",
                    action: westHouse,
                    attributes: [
                        .on,
                        .rLand,
                        .sacred,
                    ],
                    description: "West of House",
                    directions: [
                        .`in`: .conditional(stoneBarrow, if: wonFlag),
                        .east: .blocked("The door is boarded and you can't remove the boards."),
                        .north: .to(northOfHouse),
                        .northEast: .to(northOfHouse),
                        .south: .to(southOfHouse),
                        .southEast: .to(southOfHouse),
                        .southWest: .conditional(stoneBarrow, if: wonFlag),
                        .west: .to(forest1),
                    ],
                    globals: [
                        board,
                        forest,
                        whiteHouse,
                    ],
                    parent: rooms
                )
                """,
            dataType: .room,
            defType: .room,
            isMutable: true
        ))
    }

    func testReservoirSouth() throws {
        var room = Object(.room, [
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
        ])

        XCTAssertNoDifference(try room.process(), .init(
            name: "reservoirSouth",
            code: """
                /// The `reservoirSouth` (RESERVOIR-SOUTH) room.
                var reservoirSouth = Room(
                    name: "reservoirSouth",
                    action: reservoirSouthFunc,
                    attributes: [.rLand],
                    description: "Reservoir South",
                    directions: [
                        .east: .to(damRoom),
                        .north: .conditionalElse(reservoir,
                            if: lowTide,
                            else: "You would drown."
                        ),
                        .southEast: .to(deepCanyon),
                        .southWest: .to(chasmRoom),
                        .west: .to(streamView),
                    ],
                    globals: [globalWater],
                    parent: rooms,
                    pseudos: [
                        "chasm": chasmPseudo,
                        "lake": lakePseudo
                    ]
                )
                """,
            dataType: .room,
            defType: .room,
            isMutable: true
        ))
    }

    func testEastOfHouse() throws {
        var room = Object(.room, [
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
        ])

        XCTAssertNoDifference(try room.process(), .init(
            name: "eastOfHouse",
            code: """
                /// The `eastOfHouse` (EAST-OF-HOUSE) room.
                var eastOfHouse = Room(
                    name: "eastOfHouse",
                    action: eastHouse,
                    attributes: [
                        .on,
                        .rLand,
                        .sacred,
                    ],
                    description: "Behind House",
                    directions: [
                        .`in`: .conditional(kitchen, if: kitchenWindow.isOpen),
                        .east: .to(clearing),
                        .north: .to(northOfHouse),
                        .northWest: .to(northOfHouse),
                        .south: .to(southOfHouse),
                        .southWest: .to(southOfHouse),
                        .west: .conditional(kitchen, if: kitchenWindow.isOpen),
                    ],
                    globals: [
                        forest,
                        kitchenWindow,
                        whiteHouse,
                    ],
                    parent: rooms
                )
                """,
            dataType: .room,
            defType: .room,
            isMutable: true
        ))
    }

    func testStudio() throws {
        var room = Object(.room, [
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
        ])

        XCTAssertNoDifference(try room.process(), .init(
            name: "studio",
            code: #"""
                /// The `studio` (STUDIO) room.
                var studio = Room(
                    name: "studio",
                    attributes: [.rLand],
                    description: "Studio",
                    directions: [
                        .south: .to(gallery),
                        .up: .per(upChimneyFunc),
                    ],
                    globals: [chimney],
                    longDescription: """
                        This appears to have been an artist's studio. The walls and \
                        floors are splattered with paints of 69 different colors. \
                        Strangely enough, nothing of value is hanging here. At the \
                        south end of the room is an open door (also covered with \
                        paint). A dark and narrow chimney leads up from a fireplace; \
                        although you might be able to get up it, it seems unlikely \
                        you could get back down.
                        """,
                    parent: rooms,
                    pseudos: [
                        "door": doorPseudo,
                        "paint": paintPseudo
                    ]
                )
                """#,
            dataType: .room,
            defType: .room,
            isMutable: true
        ))
    }

    func testFoyer() throws {
        var room = Object(.room, [
            .atom("FOYER"),
            .list(
                [
                    .atom("DESC"),
                    .string("Foyer of the Opera House")
                ]
            ),
            .list(
                [
                    .atom("IN"),
                    .atom("ROOMS")
                ]
            ),
            .list(
                [
                    .atom("LDESC"),
                    .string("You are standing in a spacious hall, splendidly decorated in red and gold, with glittering chandeliers overhead. The entrance from the street is to the north, and there are doorways south and west.")
                ]
            ),
            .list(
                [
                    .atom("SOUTH"),
                    .atom("TO"),
                    .atom("BAR")
                ]
            ),
            .list(
                [
                    .atom("WEST"),
                    .atom("TO"),
                    .atom("CLOAKROOM")
                ]
            ),
            .list(
                [
                    .atom("NORTH"),
                    .atom("SORRY"),
                    .string("You\'ve only just arrived, and besides, the weather outside seems to be getting worse.")
                ]
            ),
            .list(
                [
                    .atom("FLAGS"),
                    .atom("LIGHTBIT")
                ]
            )
        ])

        XCTAssertNoDifference(try room.process(), .init(
            name: "foyer",
            code: #"""
                /// The `foyer` (FOYER) room.
                var foyer = Room(
                    name: "foyer",
                    attributes: [.light],
                    description: "Foyer of the Opera House",
                    directions: [
                        .north: .blocked("""
                            You've only just arrived, and besides, the weather outside \
                            seems to be getting worse.
                            """),
                        .south: .to(bar),
                        .west: .to(cloakroom),
                    ],
                    longDescription: """
                        You are standing in a spacious hall, splendidly decorated in \
                        red and gold, with glittering chandeliers overhead. The \
                        entrance from the street is to the north, and there are \
                        doorways south and west.
                        """,
                    parent: rooms
                )
                """#,
            dataType: .room,
            defType: .room,
            isMutable: true
        ))
    }


}
