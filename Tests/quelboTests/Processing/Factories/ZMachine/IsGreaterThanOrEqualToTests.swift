//
//  IsGreaterThanOrEqualToTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsGreaterThanOrEqualToTests: QuelboTests {
    let factory = Factories.IsGreaterThanOrEqualTo.self

    override func setUp() {
        super.setUp()

        Game.commit([
            Symbol(id: "foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("G=?"))
    }

    func testIsGreaterThanOrEqualTo() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "2.isGreaterThanOrEqualTo(3)",
            type: .bool
        ))
    }

    func testIsGreaterThanOrEqualToGlobal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .global("FOO"),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "2.isGreaterThanOrEqualTo(foo)",
            type: .bool
        ))
    }

    func testIsGreaterThanOrEqualToLocal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .atom("BAR"),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "2.isGreaterThanOrEqualTo(bar)",
            type: .bool
        ))
    }

    func testTypeMismatchThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2"),
                .decimal(3),
            ], with: &registry).process()
        )
    }

    func testNonIntegersThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2"),
                .string("3"),
            ], with: &registry).process()
        )
    }
}
