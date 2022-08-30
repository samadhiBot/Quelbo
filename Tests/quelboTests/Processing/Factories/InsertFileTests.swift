//
//  InsertFileTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/20/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class InsertFileTests: QuelboTests {
    let factory = Factories.InsertFile.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("INSERT-FILE"))
    }

    func testString() throws {
        let symbol = try factory.init([
            .string("parser")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                // Insert file "parser"
                """,
            type: .comment,
            confidence: .certain
        ))
    }
}
