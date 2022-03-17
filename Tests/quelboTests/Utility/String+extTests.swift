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

        XCTAssertEqual("GRANITE-WALL-F".lowerCamelCase, "graniteWallFunction")

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
            You are standing in an open field west of a white house, with a boarded
            front door.
            """
        XCTAssertNoDifference(
            string.quoted(),
            #"""
            """
                You are standing in an open field west of a white house, with a boarded
                front door.
                """
            """#
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
        XCTAssertNoDifference(string.translateMultiline, #"""
            You are outside a large gateway, on which is inscribed

              Abandon every hope \
            all ye who enter here!

            The gate is open; through it you can see a desolation, with a pile of \
            mangled bodies in one corner. Thousands of voices, lamenting some \
            hideous fate, can be heard.
            """#
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
        XCTAssertNoDifference(string.translateMultiline, #"""
              !!!!FROBOZZ MAGIC BOAT COMPANY!!!!

            Hello, Sailor!

            Instructions for use:

               To get into a body of water, say "Launch".
               To get to shore, say "Land" or the direction in which you want \
            to maneuver the boat.

            Warranty:

              This boat is guaranteed against all defects for a period of 76 \
            milliseconds from date of purchase or until first used, whichever comes first.

            Warning:
               This boat is made of thin plastic.
               Good Luck!
            """#
        )
    }

    func testUpperCamelCase() {
        XCTAssertEqual("OPEN-CLOSE".upperCamelCase, "OpenClose")

        XCTAssertEqual("GRANITE-WALL-F".upperCamelCase, "GraniteWallFunction")

        XCTAssertEqual("EQUAL?".upperCamelCase, "IsEqual")
    }
}
