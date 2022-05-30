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

        try! Game.commit([
            Symbol(id: "north", code: "case north", type: .direction, category: .directions),
            Symbol(id: "east", code: "case east", type: .direction, category: .directions),
            Symbol(id: "west", code: "case west", type: .direction, category: .directions),
            Symbol(id: "south", code: "case south", type: .direction, category: .directions),
            Symbol(id: "northEast", code: #"case northEast = "ne""#, type: .direction, category: .directions),
            Symbol(id: "northWest", code: #"case northWest = "nw""#, type: .direction, category: .directions),
            Symbol(id: "southEast", code: #"case southEast = "se""#, type: .direction, category: .directions),
            Symbol(id: "southWest", code: #"case southWest = "sw""#, type: .direction, category: .directions),
            Symbol(id: "up", code: "case up", type: .direction, category: .directions),
            Symbol(id: "down", code: "case down", type: .direction, category: .directions),
            Symbol(id: "into", code: #"case into = "in""#, type: .direction, category: .directions),
            Symbol(id: "out", code: "case out", type: .direction, category: .directions),
            Symbol(id: "land", code: "case land", type: .direction, category: .directions),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("ROOM"))
    }

    func testWestOfHouse() throws {
        let symbol = try factory.init([
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
        ], with: types).process()

        let expected = Symbol(
            id: "westOfHouse",
            code: """
                /// The `westOfHouse` (WEST-OF-HOUSE) room.
                var westOfHouse = Room(
                    action: westHouse,
                    description: "West of House",
                    directions: [
                        .north: .to(northOfHouse),
                        .south: .to(southOfHouse),
                        .northEast: .to(northOfHouse),
                        .southEast: .to(southOfHouse),
                        .west: .to(forest1),
                        .east: .blocked("The door is boarded and you can't remove the boards."),
                        .southWest: .conditional(stoneBarrow, if: wonFlag),
                        .into: .conditional(stoneBarrow, if: wonFlag),
                    ],
                    flags: [
                        isDryLand,
                        isOn,
                        isSacred,
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
            children: [
                Symbol(
                    id: "location",
                    code: "location: rooms",
                    type: .object,
                    children: [
                        Symbol("rooms", type: .object)
                    ]
                ),
                Symbol(
                    id: "description",
                    code: "description: \"West of House\"",
                    type: .string,
                    children: [
                        Symbol("\"West of House\"", type: .string, meta: [.isLiteral])
                    ]
                ),
                Symbol(
                    id: "action",
                    code: "action: westHouse",
                    type: .routine,
                    children: [
                        Symbol("westHouse", type: .routine)
                    ]
                ),
                Symbol(
                    id: "flags",
                    code: """
                     flags: [
                         isDryLand,
                         isOn,
                         isSacred,
                     ]
                     """,
                    type: .array(.bool),
                    children: [
                        Symbol(id: "rlandBit", code: "isDryLand", type: .bool, category: .flags),
                        Symbol(id: "onBit", code: "isOn", type: .bool, category: .flags),
                        Symbol(id: "sacredBit", code: "isSacred", type: .bool, category: .flags),
                    ]
                ),
                Symbol(
                    id: "globals",
                    code: """
                     globals: [
                         whiteHouse,
                         board,
                         forest,
                     ]
                     """,
                    type: .array(.object),
                    children: [
                        Symbol("whiteHouse", type: .object),
                        Symbol("board", type: .object),
                        Symbol("forest", type: .object),
                    ]
                ),
                Symbol(
                    id: "directions",
                    code: """
                     directions: [
                         .north: .to(northOfHouse),
                         .south: .to(southOfHouse),
                         .northEast: .to(northOfHouse),
                         .southEast: .to(southOfHouse),
                         .west: .to(forest1),
                         .east: .blocked("The door is boarded and you can't remove the boards."),
                         .southWest: .conditional(stoneBarrow, if: wonFlag),
                         .into: .conditional(stoneBarrow, if: wonFlag),
                     ]
                     """,
                    type: .array(.direction),
                    children: [
                        Symbol(
                            id: "north",
                            code: ".north: .to(northOfHouse)",
                            type: .direction
                        ),
                        Symbol(
                            id: "south",
                            code: ".south: .to(southOfHouse)",
                            type: .direction
                        ),
                        Symbol(
                            id: "northEast",
                            code: ".northEast: .to(northOfHouse)",
                            type: .direction
                        ),
                        Symbol(
                            id: "southEast",
                            code: ".southEast: .to(southOfHouse)",
                            type: .direction
                        ),
                        Symbol(
                            id: "west",
                            code: ".west: .to(forest1)",
                            type: .direction
                        ),
                        Symbol(
                            id: "east",
                            code: ".east: .blocked(\"The door is boarded and you can\'t remove the boards.\")",
                            type: .direction
                        ),
                        Symbol(
                            id: "southWest",
                            code: ".southWest: .conditional(stoneBarrow, if: wonFlag)",
                            type: .direction
                        ),
                        Symbol(
                            id: "into",
                            code: ".into: .conditional(stoneBarrow, if: wonFlag)",
                            type: .direction
                        )
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("westOfHouse"), expected)
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
        ], with: types).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            id: "reservoirSouth",
            code: """
            /// The `reservoirSouth` (RESERVOIR-SOUTH) room.
            var reservoirSouth = Room(
                action: reservoirSouthFunc,
                description: "Reservoir South",
                directions: [
                    .southEast: .to(deepCanyon),
                    .southWest: .to(chasmRoom),
                    .east: .to(damRoom),
                    .west: .to(streamView),
                    .north: .conditionalElse(reservoir,
                        if: lowTide,
                        else: You would drown.
                    ),
                ],
                flags: [isDryLand],
                globals: [globalWater],
                location: rooms,
                things: [
                    Thing(
                        adjectives: [],
                        nouns: ["lake"],
                        action: lakePseudo
                    ),
                    Thing(
                        adjectives: [],
                        nouns: ["chasm"],
                        action: chasmPseudo
                    ),
                ]
            )
            """,
            type: .object,
            category: .rooms
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
        ], with: types).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            id: "eastOfHouse",
            code: """
            /// The `eastOfHouse` (EAST-OF-HOUSE) room.
            var eastOfHouse = Room(
                action: eastHouse,
                description: "Behind House",
                directions: [
                    .north: .to(northOfHouse),
                    .south: .to(southOfHouse),
                    .southWest: .to(southOfHouse),
                    .northWest: .to(northOfHouse),
                    .east: .to(clearing),
                    .west: .conditional(kitchen, if: kitchenWindow.isOpen),
                    .into: .conditional(kitchen, if: kitchenWindow.isOpen),
                ],
                flags: [
                    isDryLand,
                    isOn,
                    isSacred,
                ],
                globals: [
                    whiteHouse,
                    kitchenWindow,
                    forest,
                ],
                location: rooms
            )
            """,
            type: .object,
            category: .rooms
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
        ], with: types).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            id: "studio",
            code: #"""
            /// The `studio` (STUDIO) room.
            var studio = Room(
                description: "Studio",
                directions: [
                    .south: .to(gallery),
                    .up: .per(upChimneyFunc),
                ],
                flags: [isDryLand],
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
                        adjectives: [],
                        nouns: ["door"],
                        action: doorPseudo
                    ),
                    Thing(
                        adjectives: [],
                        nouns: ["paint"],
                        action: paintPseudo
                    ),
                ]
            )
            """#,
            type: .object,
            category: .rooms
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
        ], with: types).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            id: "foyer",
            code: #"""
            /// The `foyer` (FOYER) room.
            var foyer = Room(
                description: "Foyer of the Opera House",
                directions: [
                    .south: .to(bar),
                    .west: .to(cloakroom),
                    .north: .blocked("""
                        You've only just arrived, and besides, the weather outside \
                        seems to be getting worse.
                        """),
                ],
                flags: [isLight],
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
            category: .rooms
        ))
    }

    func testInStream() throws {
        let symbol = try factory.init([
            .atom("IN-STREAM"),
            .list([
                .atom("IN"),
                .atom("ROOMS")
            ]),
            .list([
                .atom("LDESC"),
                .string("You are on the gently flowing stream. The upstream route is too narrow to navigate, and the downstream route is invisible due to twisting walls. There is a narrow beach to land on.")
            ]),
            .list([
                .atom("DESC"),
                .string("Stream")
            ]),
            .list([
                .atom("UP"),
                .string("The channel is too narrow.")
            ]),
            .list([
                .atom("WEST"),
                .string("The channel is too narrow.")
            ]),
            .list([
                .atom("LAND"),
                .atom("TO"),
                .atom("STREAM-VIEW")
            ]),
            .list([
                .atom("DOWN"),
                .atom("TO"),
                .atom("RESERVOIR")
            ]),
            .list([
                .atom("EAST"),
                .atom("TO"),
                .atom("RESERVOIR")
            ]),
            .list([
                .atom("FLAGS"),
                .atom("NONLANDBIT")
            ]),
            .list([
                .atom("GLOBAL"),
                .atom("GLOBAL-WATER")
            ]),
            .list([
                .atom("PSEUDO"),
                .string("STREAM"),
                .atom("STREAM-PSEUDO")
            ])
        ], with: types).process()

        let expected = Symbol(
            id: "inStream",
            code: #"""
            /// The `inStream` (IN-STREAM) room.
            var inStream = Room(
                description: "Stream",
                directions: [
                    .up: .blocked("The channel is too narrow."),
                    .west: .blocked("The channel is too narrow."),
                    .land: .to(streamView),
                    .down: .to(reservoir),
                    .east: .to(reservoir),
                ],
                flags: [isNotLand],
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
                        adjectives: [],
                        nouns: ["stream"],
                        action: streamPseudo
                    ),
                ]
            )
            """#,
            type: .object,
            category: .rooms,
            children: [
                Symbol(
                    id: "location",
                    code: "location: rooms",
                    type: .object,
                    children: [
                        Symbol(
                            id: "rooms",
                            code: "rooms",
                            type: .object
                        )
                    ]
                ),
                Symbol(
                    id: "longDescription",
                    code: #"""
                         longDescription: """
                             You are on the gently flowing stream. The upstream route is \
                             too narrow to navigate, and the downstream route is \
                             invisible due to twisting walls. There is a narrow beach to \
                             land on.
                             """
                         """#,
                    type: .string,
                    children: [
                        Symbol(
                            #"""
                                """
                                    You are on the gently flowing stream. The upstream route is \
                                    too narrow to navigate, and the downstream route is \
                                    invisible due to twisting walls. There is a narrow beach to \
                                    land on.
                                    """
                                """#,
                            type: .string,
                            meta: [.isLiteral]
                        )
                    ]
                ),
                Symbol(
                    id: "description",
                    code: "description: \"Stream\"",
                    type: .string,
                    children: [
                        Symbol("\"Stream\"", type: .string, meta: [.isLiteral]),
                    ]
                ),
                Symbol(
                    id: "flags",
                    code: "flags: [isNotLand]",
                    type: .array(.bool),
                    children: [
                        Symbol(id: "nonlandBit", code: "isNotLand", type: .bool, category: .flags)
                    ]
                ),
                Symbol(
                    id: "globals",
                    code: "globals: [globalWater]",
                    type: .array(.object),
                    children: [
                        Symbol("globalWater", type: .object),
                    ]
                ),
                Symbol(
                    id: "things",
                    code: """
                         things: [
                             Thing(
                                 adjectives: [],
                                 nouns: ["stream"],
                                 action: streamPseudo
                             ),
                         ]
                         """,
                    type: .array(.thing),
                    children: [
                        Symbol(
                            id: "thing",
                            code: """
                             Thing(
                                 adjectives: [],
                                 nouns: ["stream"],
                                 action: streamPseudo
                             )
                             """,
                            type: .thing
                        )
                    ]
                ),
                Symbol(
                    id: "directions",
                    code: """
                         directions: [
                             .up: .blocked("The channel is too narrow."),
                             .west: .blocked("The channel is too narrow."),
                             .land: .to(streamView),
                             .down: .to(reservoir),
                             .east: .to(reservoir),
                         ]
                         """,
                    type: .array(.direction),
                    children: [
                        Symbol(
                            id: "up",
                            code: ".up: .blocked(\"The channel is too narrow.\")",
                            type: .direction
                        ),
                        Symbol(
                            id: "west",
                            code: ".west: .blocked(\"The channel is too narrow.\")",
                            type: .direction
                        ),
                        Symbol(
                            id: "land",
                            code: ".land: .to(streamView)",
                            type: .direction
                        ),
                        Symbol(
                            id: "down",
                            code: ".down: .to(reservoir)",
                            type: .direction
                        ),
                        Symbol(
                            id: "east",
                            code: ".east: .to(reservoir)",
                            type: .direction
                        )
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("inStream"), expected)
    }
}
