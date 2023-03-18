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
            .variable(id: "foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("L=?"))
    }

    func testLessThanOrEquals() throws {
        let symbol = process("<L=? 2 3>")

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isLessThanOrEqualTo(3)",
            type: .bool
        ))
    }

    func testEvaluation() throws {
        XCTAssertNoDifference(
            process("<L=? 1 2>", mode: .evaluate),
            .true
        )

        XCTAssertNoDifference(
            process("<L=? 1 1 2>", mode: .evaluate),
            .true
        )

        XCTAssertNoDifference(
            process("<L=? 2 2 1>", mode: .evaluate),
            .false
        )
    }

    func testLessThanOrEqualsGlobal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .global(.atom("FOO")),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isLessThanOrEqualTo(Global.foo)",
            type: .bool
        ))
    }

    func testLessThanOrEqualsLocal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .atom("BAR"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isLessThanOrEqualTo(bar)",
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
