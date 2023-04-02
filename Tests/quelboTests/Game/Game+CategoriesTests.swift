//
//  Game+CategoriesTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/1/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class GameCategoriesTestsTests: QuelboTests {
    override func setUp() {
        super.setUp()

        process("""
            <DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND SEA>

            <CONSTANT M-ENTER 3>
            <CONSTANT M-LOOK 4>

            <GLOBAL FALSE-FLAG <>>
            <GLOBAL SCORE-MAX 350>

            <OBJECT BAT
                (ACTION BAT-F)
                (FLAGS ACTORBIT TRYTAKEBIT)>
            <OBJECT BELL>

            <ROOM ARAGAIN-FALLS
                (ACTION FALLS-ROOM)
                (FLAGS RLANDBIT SACREDBIT ONBIT)>
            <ROOM ON-RAINBOW>

            <ROUTINE BAT-F () <TELL "Fweep!" CR>>
            <ROUTINE FALLS-ROOM (RARG)
                <COND (<EQUAL? .RARG ,M-LOOK> <TELL "You are at the top..." CR>)>>
            <ROUTINE SAND-FUNCTION () <TELL "Dig!" CR>>

            <SYNTAX CUT OBJECT WITH OBJECT (FIND WEAPONBIT) (CARRIED HELD) = V-CUT>
            <SYNONYM CUT SLICE PIERCE>
            <SYNTAX DEFLATE OBJECT = V-DEFLATE>
        """)
    }

    func testActions() {
        XCTAssertNoDifference(Game.actionRoutines.map(\.handle), [
            "batFunc",
            "fallsRoom",
        ])
    }

    func testConstants() {
        XCTAssertNoDifference(Game.constants.map(\.handle), [
            "lowDirection",
            "zilch",
            "mEnter",
            "mLook",
        ])
    }

    func testDirections() {
        XCTAssertNoDifference(Game.directions.map(\.code), [
            """
            /// Represents an exit toward land.
            public static let land = Direction(id: "land")

            /// Represents an exit toward sea.
            public static let sea = Direction(id: "sea")
            """
        ])
    }

    func testFlags() {
        XCTAssertNoDifference(Game.flags.map(\.handle), [
            ".isActor",
            ".noImplicitTake",
            ".isDryLand",
            ".isSacred",
            ".isOn",
        ])
    }

    func testGlobals() {
        XCTAssertNoDifference(Game.globals.map(\.handle), [
            "actions",
            "parsedVerb",
            "parsedIndirectObject",
            "parsedDirectObject",
            "preactions",
            "prepositions",
            "verbs",
            "falseFlag",
            "scoreMax",
        ])
    }

    func testNonActionRoutines() {
        XCTAssertNoDifference(Game.nonActionRoutines.map(\.handle), [
            "nullFunc",
            "sandFunc"
        ])
    }

    func testObjects() {
        XCTAssertNoDifference(Game.objects.map(\.handle), [
            "bat",
            "bell",
        ])
    }

    func testProperties() {
        XCTAssertNoDifference(Game.properties.map(\.handle), [
            "north",
            "east",
            "west",
            "south",
            "northEast",
            "northWest",
            "southEast",
            "southWest",
            "up",
            "down",
            "in",
            "out",
            "land",
            "sea",
        ])
    }

    func testRooms() {
        XCTAssertNoDifference(Game.rooms.map(\.handle), [
            "aragainFalls",
            "onRainbow",
        ])
    }

    func testRoutines() {
        XCTAssertNoDifference(Game.routines.map(\.handle), [
            "nullFunc",
            "batFunc",
            "fallsRoom",
            "sandFunc",
        ])
    }

    func testSyntax() {
        XCTAssertNoDifference(Game.syntax.map(\.handle), [
            "cutObjectWithObject",
            "synonym:cut",
            "deflateObject",
        ])
    }
}
