//
//  DecrementLessThanTests.swift.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DecrementLessThanTests: QuelboTests {
    let factory = Factories.DecrementLessThan.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("DLESS?"))
    }

    func testDecrementLessThan() throws {
        localVariables.append(
            Statement(id: "foo", type: .int)
        )

        let symbol = try factory.init([
            .local("FOO"),
            .decimal(3),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "foo.decrement().isLessThan(3)",
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
