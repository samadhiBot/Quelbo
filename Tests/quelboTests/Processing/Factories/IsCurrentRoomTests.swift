//
//  IsCurrentRoomTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsCurrentRoomTests: QuelboTests {
    let factory = Factories.IsCurrentRoom.self

    override func setUp() {
        super.setUp()

        process("""
            <ROOM ARAGAIN-FALLS>
            <ROOM SANDY-CAVE>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ROOM?"))
    }

    func testIsCurrentRoomSingle() throws {
        let symbol = process("<ROOM? ARAGAIN-FALLS>")

        XCTAssertNoDifference(symbol, .statement(
            code: """
                isCurrentRoom(Rooms.aragainFalls)
                """,
            type: .bool
        ))
    }

    func testIsCurrentRoomMultiple() throws {
        let symbol = process("<ROOM? ARAGAIN-FALLS SANDY-CAVE>")

        XCTAssertNoDifference(symbol, .statement(
            code: """
                isCurrentRoom(Rooms.aragainFalls, Rooms.sandyCave)
                """,
            type: .bool
        ))
    }
}
