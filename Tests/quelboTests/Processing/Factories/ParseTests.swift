//
//  ParseTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ParseTests: QuelboTests {
    let factory = Factories.Parse.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PARSE"))
    }

    func testParse() throws {
        let symbol = process(
            """
                <PARSE <STRING "V?" <SPNAME .ATM>>>
            """,
            with: [Statement(id: "atm", type: .string)]
        )

        XCTAssertNoDifference(symbol, .statement(
            id: nil,
            code: """
                [["V?", atm.id].joined()].parse()
                """,
            type: .verb
        ))
    }
}
