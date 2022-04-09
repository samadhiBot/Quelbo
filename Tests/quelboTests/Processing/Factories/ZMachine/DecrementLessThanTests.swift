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

    override func setUp() {
        super.setUp()

        try! Game.commit([

        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("DLESS?"))
    }

    func testDecrementLessThan() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "foo.decrement().lessThan(3)",
            type: .bool,
            children: [
                Symbol("foo", type: .int),
                Symbol("3", type: .int),
            ]
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ]).process()
        )
    }
}
