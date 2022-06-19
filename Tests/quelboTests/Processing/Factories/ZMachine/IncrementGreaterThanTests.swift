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
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("IGRTR?"))
    }

    func testIncrementGreaterThan() throws {
        let symbol = try factory.init([
            .local("FOO"),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "foo.increment().isGreaterThan(3)",
            type: .bool,
            children: [
                Symbol("foo", type: .variable(.int), meta: [.mutating(true)]),
                Symbol("3", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testNonVariableThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ]).process()
        )
    }

    func testNonIntegerComparatorThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .local("FOO"),
                .string("three"),
            ]).process()
        )
    }
}
