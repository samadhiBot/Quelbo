//
//  IsGreaterThanTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsGreaterThanTests: QuelboTests {
    let factory = Factories.IsGreaterThan.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol(id: "foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("G?"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("GRTR?"))
    }

    func testIsGreaterThan() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.isGreaterThan(3)",
            type: .bool
        ))
    }

    func testIsGreaterThanGlobal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .global("FOO"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.isGreaterThan(foo)",
            type: .bool
        ))
    }

    func testIsGreaterThanLocal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .atom("BAR"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.isGreaterThan(bar)",
            type: .bool
        ))
    }

    func testTypeMismatchThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2"),
                .decimal(3),
            ]).process()
        )
    }

    func testNonIntegersThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2"),
                .string("3"),
            ]).process()
        )
    }
}
