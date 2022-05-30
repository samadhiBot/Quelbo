//
//  IsLessThanTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsLessThanTests: QuelboTests {
    let factory = Factories.IsLessThan.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol("foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("L?"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("LESS?"))
    }

    func testLessThan() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.isLessThan(3)",
            type: .bool,
            children: [
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol("3", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testLessThanGlobal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .global("FOO"),
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.isLessThan(foo)",
            type: .bool,
            children: [
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol("foo", type: .int, category: .globals),
            ]
        ))
    }

    func testLessThanLocal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .atom("BAR"),
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.isLessThan(bar)",
            type: .bool,
            children: [
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol("bar", type: .int),
            ]
        ))
    }

    func testTypeMismatchThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2"),
                .decimal(3),
            ], with: types).process()
        )
    }

    func testNonIntegersThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2"),
                .string("3"),
            ], with: types).process()
        )
    }
}
