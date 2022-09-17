//
//  PropertyDefaultTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/1/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PropertyDefaultTests: QuelboTests {
    let factory = Factories.PropertyDefault.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PROPDEF"))
    }

    func testBool() throws {
        let symbol = try factory.init([
            .atom("ADJECTIVE"),
            .bool(false)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "setPropertyDefault(adjective, false)",
            type: .booleanFalse
        ))
    }

    func testDecimal() throws {
        let symbol = try factory.init([
            .atom("SIZE"),
            .decimal(5)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "setPropertyDefault(size, 5)",
            type: .int
        ))
    }

    func testUnknownReturnValueThrows() throws {
        XCTAssertThrowsError(
            _ = try factory.init([
                .atom("FOO"),
                .atom("unexpected")
            ], with: &localVariables).process()
        )
    }
}
