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
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("PROPDEF"))
    }

    func testAtom() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("FOO"),
                .atom("unexpected")
            ], with: types).process()
        )
    }

    func testBool() throws {
        let symbol = try factory.init([
            .atom("ADJECTIVE"),
            .bool(false)
        ], with: types).process()

        let expected = Symbol(
            id: "adjective",
            code: "setPropertyDefault(adjective, false)",
            type: .bool,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("adjective", category: .constants), expected)
    }

    func testDecimal() throws {
        let symbol = try factory.init([
            .atom("SIZE"),
            .decimal(5)
        ], with: types).process()

        let expected = Symbol(
            id: "size",
            code: "setPropertyDefault(size, 5)",
            type: .int,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("size", category: .constants), expected)
    }
}
