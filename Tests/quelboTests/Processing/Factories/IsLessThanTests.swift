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
            .variable(id: "foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("L?"))
        AssertSameFactory(factory, Game.findFactory("LESS?"))
    }

    func testLessThan() throws {
        let symbol = process("<LESS? 2 3>")

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isLessThan(3)",
            type: .bool
        ))
    }

    func testEvaluation() throws {
        XCTAssertNoDifference(
            process("<L=? 1 2>", mode: .evaluate),
            .true
        )

        XCTAssertNoDifference(
            process("<L=? 1 2 3>", mode: .evaluate),
            .true
        )

        XCTAssertNoDifference(
            process("<LESS? 1 1>", mode: .evaluate),
            .false
        )

        XCTAssertNoDifference(
            process("<L=? 2 3 1>", mode: .evaluate),
            .false
        )
    }

    func testLessThanGlobal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .global(.atom("FOO")),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isLessThan(Globals.foo)",
            type: .bool
        ))
    }

    func testLessThanLocal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .atom("BAR"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isLessThan(bar)",
            type: .bool
        ))
    }

    func testTypeMismatchThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2"),
                .decimal(3),
            ], with: &localVariables).process()
        )
    }

    func testNonIntegersThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2"),
                .string("3"),
            ], with: &localVariables).process()
        )
    }
}
