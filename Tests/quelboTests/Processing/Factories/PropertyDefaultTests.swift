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
        let symbol = process("<PROPDEF ADJECTIVE <>>")

        XCTAssertNoDifference(symbol, .statement(
            code: "setPropertyDefault(adjective, false)",
            type: .bool
        ))
    }

    func testDecimal() throws {
        let symbol = process("<PROPDEF SIZE 5>")

        XCTAssertNoDifference(symbol, .statement(
            code: "setPropertyDefault(size, 5)",
            type: .int
        ))
    }
}
