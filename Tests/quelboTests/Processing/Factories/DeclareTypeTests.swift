//
//  DeclareTypeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/23/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DeclareTypeTests: QuelboTests {
    let factory = Factories.DeclareType.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("#DECL"))
    }

    func testDeclareType() throws {
        let symbol = process("<GDECL (BEACH-DIG) FIX>")

        XCTAssertNoDifference(symbol, .statement(
            code: "",
            type: .comment
        ))
    }
}
