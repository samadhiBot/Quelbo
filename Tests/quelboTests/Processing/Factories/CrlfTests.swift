//
//  CrlfTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class CrlfTests: QuelboTests {
    let factory = Factories.Crlf.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("CRLF"))
    }

    func testCrlf() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"output("\n")"#,
            type: .void,
            confidence: .void,
            returnable: .void
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42)
            ], with: &localVariables).process()
        )
    }
}
