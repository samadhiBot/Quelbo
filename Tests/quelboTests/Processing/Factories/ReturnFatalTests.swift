//
//  ReturnFatalTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ReturnFatalTests: QuelboTests {
    let factory = Factories.ReturnFatal.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("RFATAL"))
    }

    func testReturnFatal() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "returnFatal()",
            type: .void
        ))
    }

    func testReturnFatalWithParameterThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ], with: &localVariables).process()
        )
    }
}
