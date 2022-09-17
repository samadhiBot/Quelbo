//
//  VerifyTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class VerifyTests: QuelboTests {
    let factory = Factories.Verify.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("VERIFY"))
    }

    func testVerify() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "verify()",
            type: .void
        ))

    }

    func testVerifyWithParameterThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ], with: &localVariables).process()
        )
    }
}
