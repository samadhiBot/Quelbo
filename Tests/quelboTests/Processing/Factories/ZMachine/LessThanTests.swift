//
//  LessThanTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class LessThanTests: QuelboTests {
    let factory = Factories.LessThan.self

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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.lessThan(3)",
            type: .bool,
            children: [
                Symbol("2", type: .int),
                Symbol("3", type: .int),
            ]
        ))
    }

    func testLessThanGlobal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .atom(",FOO"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.lessThan(foo)",
            type: .bool,
            children: [
                Symbol("2", type: .int),
                Symbol("foo", type: .int, category: .globals),
            ]
        ))
    }

    func testLessThanLocal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .atom("BAR"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.lessThan(bar)",
            type: .bool,
            children: [
                Symbol("2", type: .int),
                Symbol("bar", type: .int),
            ]
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