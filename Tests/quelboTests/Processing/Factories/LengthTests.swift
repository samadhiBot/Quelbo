//
//  LengthTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class LengthTests: QuelboTests {
    let factory = Factories.Length.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("LENGTH"))
    }

    func testLength() throws {
        localVariables.append(
            Variable(id: "atms", type: .array(.zilElement))
        )

        let symbol = try factory.init([
            .local("ATMS")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "atms.count",
            type: .int,
            confidence: .certain
        ))
    }
}
