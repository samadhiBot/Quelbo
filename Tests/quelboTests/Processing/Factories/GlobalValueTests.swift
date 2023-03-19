//
//  GlobalValueTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GlobalValueTests: QuelboTests {
    let factory = Factories.GlobalValue.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("GVAL"))
    }

    func testAtom() throws {
        process("<GLOBAL FOO 42>")

        let symbol = try factory.init([
            .atom("FOO")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .instance(.init(
            id: "foo",
            code: "var foo = 42",
            type: .int,
            category: .globals,
            isCommittable: true,
            isMutable: true
        )))
    }
}
