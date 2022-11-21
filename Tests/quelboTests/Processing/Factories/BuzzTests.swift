//
//  BuzzTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class BuzzTests: QuelboTests {
    let factory = Factories.Buzz.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("BUZZ"))
    }

    func testBuzz() throws {
        let symbol = process(#"""
            <BUZZ A AN THE IS AND OF THEN ALL ONE BUT EXCEPT \. \, \" YES NO Y HERE>
        """#)

        XCTAssertNoDifference(symbol, .statement(
            code: #"""
                Syntax.ignore([
                    "a",
                    "an",
                    "the",
                    "is",
                    "and",
                    "of",
                    "then",
                    "all",
                    "one",
                    "but",
                    "except",
                    "\.",
                    "\,",
                    "\\"",
                    "yes",
                    "no",
                    "y",
                    "here",
                ])
                """#,
            type: .void,
            category: .syntax,
            isCommittable: true
        ))
    }
}
