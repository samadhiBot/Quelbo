//
//  IsZeroTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsZeroTests: QuelboTests {
    let factory = Factories.IsZero.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("0?"))
        AssertSameFactory(factory, Game.findFactory("ZERO?"))
    }

    func testIsZero() throws {
        let symbol = try factory.init([
            .decimal(2)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isZero",
            type: .bool
        ))
    }

    func testIsZeroGlobal() throws {
        let symbol = try factory.init([
            .global(.atom("FOO"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "foo.isZero",
            type: .bool
        ))
    }

    func testIsZeroLocal() throws {
        localVariables.append(
            Statement(id: "bar", type: .int)
        )

        let symbol = try factory.init([
            .local("BAR")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "bar.isZero",
            type: .bool
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2")
            ], with: &localVariables).process()
        )
    }
}
