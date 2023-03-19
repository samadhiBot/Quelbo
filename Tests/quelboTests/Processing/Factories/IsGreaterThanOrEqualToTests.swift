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

        try! Game.commit([
            .variable(id: "foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("G=?"))
    }

    func testIsGreaterThanOrEqualTo() throws {
        let symbol = process("<G=? 2 3>")

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isGreaterThanOrEqualTo(3)",
            type: .bool
        ))
    }

    func testEvaluation() throws {
        XCTAssertNoDifference(
            process("<G=? 2 1>", mode: .evaluate),
            .true
        )

        XCTAssertNoDifference(
            process("<G=? 3 1 2>", mode: .evaluate),
            .true
        )

        XCTAssertNoDifference(
            process("<G=? 2 2 2>", mode: .evaluate),
            .true
        )

        XCTAssertNoDifference(
            process("<G=? 1 2>", mode: .evaluate),
            .false
        )
    }

    func testIsGreaterThanOrEqualToGlobal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .global(.atom("FOO")),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isGreaterThanOrEqualTo(Globals.foo)",
            type: .bool
        ))
    }

    func testIsGreaterThanOrEqualToLocal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .atom("BAR"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isGreaterThanOrEqualTo(bar)",
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
