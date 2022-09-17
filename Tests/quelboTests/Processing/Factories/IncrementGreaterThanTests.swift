//
//  IncrementGreaterThanTests.swift.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IncrementGreaterThanTests: QuelboTests {
    let factory = Factories.IncrementGreaterThan.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("IGRTR?"))
    }

    func testIncrementGreaterThan() throws {
        localVariables.append(
            Variable(id: "foo", type: .int)
        )

        let symbol = try factory.init([
            .local("FOO"),
            .decimal(3),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "foo.increment().isGreaterThan(3)",
            type: .bool
        ))
    }

    func testNonVariableThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ], with: &localVariables).process()
        )
    }

    func testNonIntegerComparatorThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .local("FOO"),
                .string("three"),
            ], with: &localVariables).process()
        )
    }
}
