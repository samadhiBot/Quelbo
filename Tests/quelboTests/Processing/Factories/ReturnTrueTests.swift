//
//  ReturnTrueTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ReturnTrueTests: QuelboTests {
    let factory = Factories.ReturnTrue.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("RTRUE"))
    }

    func testReturnTrue() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "return true",
            type: .booleanTrue,
            returnHandling: .forced
        ))
    }

    func testAnyParamThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .bool(true)
            ], with: &localVariables).process()
        )
    }
}
