//
//  IsLessThanOrEqualToTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsLessThanOrEqualToTests: QuelboTests {
    let factory = Factories.IsLessThanOrEqualTo.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol("foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("L=?"))
    }

    func testLessThanOrEquals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.isLessThanOrEqualTo(3)",
            type: .bool,
            children: [
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol("3", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testLessThanOrEqualsGlobal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .global("FOO"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.isLessThanOrEqualTo(foo)",
            type: .bool,
            children: [
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol("foo", type: .int, category: .globals),
            ]
        ))
    }

    func testLessThanOrEqualsLocal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .atom("BAR"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.isLessThanOrEqualTo(bar)",
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
