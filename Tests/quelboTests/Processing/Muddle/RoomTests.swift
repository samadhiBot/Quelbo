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
        var Room = Room([
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

        XCTAssertNoDifference(try Room.process(), .init(
            name: "westOfHouse",
            code: """
                /// The `westOfHouse` (WEST-OF-HOUSE) Room.
                var westOfHouse = Room(
                    name: "westOfHouse",
                    action: westHouse,
                    description: "West of House",
                    directions: [
                        north: .to(northOfHouse)
                        south: .to(southOfHouse)
                        northEast: .to(northOfHouse)
                        southEast: .to(southOfHouse)
                        west: .to(forest1)
                        east: .blocked(message: "The door is boarded and you can't remove the boards.")
                        southWest: .conditional(
                            to: stoneBarrow,
                            if: wonFlag
                        )
                    ],
                    flags: [rlandbit, onbit, sacredbit],
                    globals: [whiteHouse, board, forest],
                    parent: rooms,
                    parent: to
                )
                """,
            dataType: .room,
            defType: .room
        ))
    }

    func testReservoirSouth() throws {
        var Room = Room([
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

        XCTAssertNoDifference(try Room.process(), .init(
            name: "reservoirSouth",
            code: """
                /// The `reservoirSouth` (RESERVOIR-SOUTH) Room.
                var reservoirSouth = Room(
                    name: "reservoirSouth",
                    action: reservoirSouthFcn,
                    description: "Reservoir South",
                    directions: [
                        southEast: .to(deepCanyon)
                        southWest: .to(chasmRoom)
                        east: .to(damRoom)
                        west: .to(streamView)
                        north: .conditionalElse(
                            to: reservoir,
                            if: lowTide,
                            else: "You would drown."
                        )
                    ],
                    flags: [rlandbit],
                    globals: [globalWater],
                    parent: rooms,
                    pseudos: [
                        "chasm": chasmPseudo,
                        "lake": lakePseudo
                    ]
                )
                """,
            dataType: .room,
            defType: .room
        ))
    }

    func testEastOfHouse() throws {
        var Room = Room([
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

        XCTAssertNoDifference(try Room.process(), .init(
            name: "eastOfHouse",
            code: """
                /// The `eastOfHouse` (EAST-OF-HOUSE) Room.
                var eastOfHouse = Room(
                    name: "eastOfHouse",
                    action: eastHouse,
                    description: "Behind House",
                    directions: [
                        north: .to(northOfHouse)
                        south: .to(southOfHouse)
                        southWest: .to(southOfHouse)
                        northWest: .to(northOfHouse)
                        east: .to(clearing)
                        west: .conditional(
                            to: kitchen,
                            if: kitchenWindow.isOpen
                        )
                    ],
                    flags: [rlandbit, onbit, sacredbit],
                    globals: [whiteHouse, kitchenWindow, forest],
                    parent: rooms,
                    parent: to
                )
                """,
            dataType: .room,
            defType: .room
        ))
    }

    func testStudio() throws {
        var Room = Room([
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

        XCTAssertNoDifference(try Room.process(), .init(
            name: "studio",
            code: #"""
                /// The `studio` (STUDIO) Room.
                var studio = Room(
                    name: "studio",
                    description: "Studio",
                    directions: [
                        south: .to(gallery)
                        up: .per(upChimneyFunction)
                    ],
                    flags: [rlandbit],
                    globals: [chimney],
                    longDescription: """
                        This appears to have been an artist's studio. The walls and \
                        floors are splattered with paints of 69 different colors. \
                        Strangely enough, nothing of value is hanging here. At the \
                        south end of the room is an open door (also covered with \
                        paint). A dark and narrow chimney leads up from a \
                        fireplace; although you might be able to get up it, it \
                        seems unlikely you could get back down.
                        """,
                    parent: rooms,
                    pseudos: [
                        "door": doorPseudo,
                        "paint": paintPseudo
                    ]
                )
                """#,
            dataType: .room,
            defType: .room
        ))
    }
}
