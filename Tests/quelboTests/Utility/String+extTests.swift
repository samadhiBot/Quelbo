//
//  String+extTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class StringExtTests: XCTestCase {
    func testConvertToMultiline() {
        XCTAssertEqual(
            """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            """.convertToMultiline(),
            #"""
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed \
            do eiusmod tempor incididunt ut labore et dolore magna \
            aliqua. Ut enim ad minim veniam, quis nostrud exercitation \
            ullamco laboris nisi ut aliquip ex ea commodo consequat. \
            Duis aute irure dolor in reprehenderit in voluptate velit \
            esse cillum dolore eu fugiat nulla pariatur. Excepteur sint \
            occaecat cupidatat non proident, sunt in culpa qui officia \
            deserunt mollit anim id est laborum.
            """#
        )
    }

    func testConvertToMultilineShortString() {
        XCTAssertEqual("hello".convertToMultiline(), "hello")
    }

    func testConvertToMultilineAlreadyMultiline() {
        XCTAssertEqual(
            """
            I'm already

            multiline!
            """.convertToMultiline(),
            """
            I'm already

            multiline!
            """
        )
    }

    func testConvertToMultilineCustomLimit() {
        XCTAssertEqual(
            """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            """.convertToMultiline(limit: 20),
            #"""
            Lorem ipsum dolor \
            sit amet, \
            consectetur \
            adipiscing elit, sed \
            do eiusmod tempor \
            incididunt ut labore \
            et dolore magna \
            aliqua.
            """#
        )
    }

    func testConvertToMultilineHandleTooLongWord() {
        XCTAssertEqual(
            """
            Lorem ipsum dolor sit amet, LoremIpsumDolorSitAmetConsecteturAdipiscingElit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            """.convertToMultiline(limit: 20),
            #"""
            Lorem ipsum dolor \
            sit amet, \
            LoremIpsumDolorSitAmetConsecteturAdipiscingElit, \
            sed do eiusmod \
            tempor incididunt ut \
            labore et dolore \
            magna aliqua.
            """#
        )
    }

    func testIndented() {
        XCTAssertEqual("hello".indented(0), "hello")

        XCTAssertEqual(
            """
            Hello
            world
            """.indented(1),
            """
                Hello
                world
            """
        )

        XCTAssertEqual(
            """
            if foo == bar {
                print("It's happening!")
            }
            """.indented(2),
            """
                    if foo == bar {
                        print("It's happening!")
                    }
            """
        )
    }

    func testLowerCamelCase() {
        XCTAssertEqual("OPEN-CLOSE".lowerCamelCase, "openClose")

        XCTAssertEqual("GRANITE-WALL-F".lowerCamelCase, "graniteWallFunc")

        XCTAssertEqual("EQUAL?".lowerCamelCase, "isEqual")
    }

    func testQuoted() {
        let string = " A secret path leads southwest into the forest."
        XCTAssertEqual(
            string.quoted(),
            #"""
            " A secret path leads southwest into the forest."
            """#
        )
    }

    func testQuotedMultiline() {
        let string = """
            "WELCOME TO ZORK!

            ZORK is a game of adventure, danger, and low cunning. In it you \
            will explore some of the most amazing territory ever seen by mortals. \
            No computer should be without one!"
            """
        XCTAssertNoDifference(
            string.quoted(),
            #"""
            """
                "WELCOME TO ZORK!
                *
                ZORK is a game of adventure, danger, and low cunning. In it \
                you will explore some of the most amazing territory ever \
                seen by mortals. No computer should be without one!"
                """
            """#.replacingOccurrences(of: "*", with: "")
        )
    }

    func testTranslateMultiline() {
        let string = """
        You are outside a large gateway, on which is inscribed||
          Abandon every hope
        all ye who enter here!||
        The gate is open; through it you can see a desolation, with a pile of
        mangled bodies in one corner. Thousands of voices, lamenting some
        hideous fate, can be heard.
        """
        XCTAssertNoDifference(string.translateMultiline, """
            You are outside a large gateway, on which is inscribed

              Abandon every hope all ye who enter here!

            The gate is open; through it you can see a desolation, with \
            a pile of mangled bodies in one corner. Thousands of voices, \
            lamenting some hideous fate, can be heard.
            """
        )
    }

    func testTranslateMultilineNestedQuotes() {
        let string = """
              !!!!FROBOZZ MAGIC BOAT COMPANY!!!!|
            |
            Hello, Sailor!|
            |
            Instructions for use:|
            |
               To get into a body of water, say \"Launch\".|
               To get to shore, say \"Land\" or the direction in which you want
            to maneuver the boat.|
            |
            Warranty:|
            |
              This boat is guaranteed against all defects for a period of 76
            milliseconds from date of purchase or until first used, whichever comes first.|
            |
            Warning:|
               This boat is made of thin plastic.|
               Good Luck!
            """
        XCTAssertNoDifference(string.translateMultiline, """
              !!!!FROBOZZ MAGIC BOAT COMPANY!!!!

            Hello, Sailor!

            Instructions for use:

               To get into a body of water, say "Launch".
               To get to shore, say "Land" or the direction in which you want \
            to maneuver the boat.

            Warranty:

              This boat is guaranteed against all defects for a period of \
            76 milliseconds from date of purchase or until first used, \
            whichever comes first.

            Warning:
               This boat is made of thin plastic.
               Good Luck!
            """
        )
    }

    func testTranslateMultilineQuoted() {
        let string = """
        Cloak of Darkness|
        A basic IF demonstration.|
        Original game by Roger Firth|
        ZIL conversion by Jesse McGrew, Jayson Smith, and Josh Lawrence
        """
        XCTAssertNoDifference(string.translateMultiline.quoted(), #"""
            """
                Cloak of Darkness
                A basic IF demonstration.
                Original game by Roger Firth
                ZIL conversion by Jesse McGrew, Jayson Smith, and Josh \
                Lawrence
                """
            """#
        )
    }

    func testUpperCamelCase() {
        XCTAssertEqual("OPEN-CLOSE".upperCamelCase, "OpenClose")

        XCTAssertEqual("GRANITE-WALL-F".upperCamelCase, "GraniteWallFunc")

        XCTAssertEqual("EQUAL?".upperCamelCase, "IsEqual")
    }
}
