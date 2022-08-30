//
//  LengthEqualsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class LengthEqualsTests: QuelboTests {
    let factory = Factories.LengthEquals.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("LENGTH?"))
    }

    func testLengthEquals() throws {
        localVariables.append(
            Variable(id: "atms", type: .array(.zilElement))
        )

        let symbol = try factory.init([
            .local("ATMS"),
            .decimal(5)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "atms.count == 5",
            type: .bool,
            confidence: .certain
        ))
    }
}
