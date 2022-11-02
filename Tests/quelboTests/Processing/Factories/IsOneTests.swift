//
//  IsOneTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsOneTests: QuelboTests {
    let factory = Factories.IsOne.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("1?"))
    }

    func testIsOne() throws {
        let symbol = try factory.init([
            .decimal(2)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isOne",
            type: .bool
        ))
    }

    func testIsOneGlobal() throws {
        let symbol = try factory.init([
            .global(.atom("FOO"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "foo.isOne",
            type: .bool
        ))
    }

    func testIsOneLocal() throws {
        localVariables.append(
            Statement(id: "bar", type: .int)
        )

        let symbol = try factory.init([
            .local("BAR")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "bar.isOne",
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
