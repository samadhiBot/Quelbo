//
//  TableTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/3/22.
//

import Foundation

import CustomDump
import XCTest
@testable import quelbo

final class LengthTableTests: QuelboTests {
    let factory = Factories.LengthTable.self

    override func setUp() {
        super.setUp()

        process("""
            <OBJECT KNIFE>
            <OBJECT SWORD>
            <OBJECT THIEF>
            <OBJECT TROLL>
            <ROOM CLEARING>
            <ROOM FOREST1>
            <ROOM FOREST2>
            <ROOM FOREST3>
            <ROOM PATH>
            <GLOBAL THIEF-MELEE <TABLE (PURE) "The thief swings his knife, but it misses.">>
            <GLOBAL TROLL-MELEE <TABLE (PURE) "The troll swings his axe, but it misses.">>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("LTABLE"))
    }

    func testTableOfRooms() throws {
        let symbol = process("""
            <LTABLE FOREST-1 FOREST-2 FOREST-3>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    .room("Room.forest1"),
                    .room("Room.forest2"),
                    .room("Room.forest3"),
                    flags: .length
                )
                """,
            type: .table,
            isMutable: true,
            returnHandling: .implicit
        ))
    }

    func testTableOfDifferentTypes() throws {
        let symbol = process("""
            <LTABLE TROLL SWORD 1 0 TROLL-MELEE>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    .object("Object.troll"),
                    .object("Object.sword"),
                    .int(1),
                    .int(0),
                    .table(Constant.trollMelee),
                    flags: .length
                )
                """,
            type: .table,
            isMutable: true,
            returnHandling: .implicit
        ))
    }

    func testLengthTableWithLeadingZero() throws {
        let symbol = process("""
            <GLOBAL JUMPLOSS
                <LTABLE 0
                       "You should have looked before you leaped."
                       "In the movies, your life would be passing before your eyes."
                       "Geronimo...">>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "jumploss",
            code: """
                var jumploss = Table(
                    "You should have looked before you leaped.",
                    "In the movies, your life would be passing before your eyes.",
                    "Geronimo...",
                    flags: .length
                )
                """,
            type: .table.root,
            category: .globals,
            isCommittable: true
        ))
    }

    func testFormPureTable() throws {
        let symbol = process("""
            <LTABLE (PURE) FOREST-1 FOREST-2 FOREST-3 PATH CLEARING FOREST-1>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    .room("Room.forest1"),
                    .room("Room.forest2"),
                    .room("Room.forest3"),
                    .room("Room.path"),
                    .room("Room.clearing"),
                    .room("Room.forest1"),
                    flags: .length
                )
                """,
            type: .table,
            isMutable: false,
            returnHandling: .implicit
        ))
    }

    func testNestedTables() throws {
        let symbol = process("""
            <LTABLE
              <LTABLE TROLL SWORD 1 0 TROLL-MELEE>
              <TABLE THIEF KNIFE 1 0 THIEF-MELEE>>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    .table(
                        .object("Object.troll"),
                        .object("Object.sword"),
                        .int(1),
                        .int(0),
                        .table(Constant.trollMelee),
                        flags: .length
                    ),
                    .table(
                        .object("Object.thief"),
                        .object("Object.knife"),
                        .int(1),
                        .int(0),
                        .table(Constant.thiefMelee)
                    ),
                    flags: .length
                )
                """,
            type: .table,
            isMutable: true,
            returnHandling: .implicit
        ))
    }

    func testGlobalTable() throws {
        process("""
            <GLOBAL HELLOS
                <LTABLE 0 "Hello."
                       "Good day."
                       "Nice weather we've been having lately."
                       "Goodbye.">>
        """)

        XCTAssertNoDifference(
            Game.globals.find("hellos"),
            Statement(
                id: "hellos",
                code: """
                    var hellos = Table(
                        "Hello.",
                        "Good day.",
                        "Nice weather we've been having lately.",
                        "Goodbye.",
                        flags: .length
                    )
                    """,
                type: .table.root,
                category: .globals,
                isCommittable: true
            )
        )
    }
}
