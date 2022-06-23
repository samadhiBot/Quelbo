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
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("DLESS?"))
    }

    func testDecrementLessThan() throws {
        let symbol = try factory.init([
            .local("FOO"),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "foo.decrement().isLessThan(3)",
            type: .bool
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
