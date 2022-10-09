//
//  RandomTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/31/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RandomTests: QuelboTests {
    let factory = Factories.Random.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("RANDOM"))
    }

    func testRandomLiteral() throws {
        let symbol = try factory.init([
            .decimal(2)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".random(2)",
            type: .int
        ))
    }

    func testRandomGlobal() throws {
        let symbol = try factory.init([
            .global(.atom("FOO"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".random(foo)",
            type: .int
        ))
    }

    func testRandomLocal() throws {
        localVariables.append(
            Variable(id: "bar", type: .int)
        )

        let symbol = try factory.init([
            .local("BAR")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".random(bar)",
            type: .int
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
