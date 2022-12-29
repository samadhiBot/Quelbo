//
//  LocalValueTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class LocalValueTests: QuelboTests {
    let factory = Factories.LocalValue.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("LVAL"))
    }

    func testAtom() throws {
        let symbol = try factory.init([
            .atom("FOO")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .variable(
            id: "foo",
            type: .unknown,
            isCommittable: false,
            returnHandling: .forced
        ))
    }
}
