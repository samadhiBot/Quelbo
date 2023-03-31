//
//  IfDebugTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class IfDebugTests: QuelboTests {
    let factory = Factories.IfDebug.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("IF-DEBUG"))
        AssertSameFactory(factory, Game.findFactory("IF-DEBUGGING-VERBS"))
    }

    func testIfDebug() throws {
        let symbol = process("""
            ;"Debugging verbs"
            <IF-DEBUG
                <SYNTAX XTRACE OBJECT = V-XTRACE>>
        """)

        XCTAssertNoDifference(symbol, .emptyStatement)
    }

    func testIfDebugEvaluate() throws {
        let symbol = process("""
            ;"Debugging verbs"
            <IF-DEBUG <+ 2 2>>
        """, mode: .evaluate)

        XCTAssertNoDifference(symbol, .false)
    }
}
