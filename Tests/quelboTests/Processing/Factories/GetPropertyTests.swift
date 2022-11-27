//
//  GetPropertyTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GetPropertyTests: QuelboTests {
    let factory = Factories.GetProperty.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "count", type: .int),
            .variable(id: "troll", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("GETP"))
        AssertSameFactory(factory, Game.findFactory("GETPT"))
    }

    func testGetProperty() throws {
        let symbol = process("""
            <GETP TROLL ,P?STRENGTH>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: "troll.strength",
            type: .int.property
        ))
    }

    func testGetPropertyAddress() throws {
        let symbol = process("""
            <GETPT TROLL ,P?STRENGTH>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: "troll.strength",
            type: .int.property
        ))
    }

    func testPropertyAddressOfObjectInLocal() throws {
        localVariables.append(
            Statement(id: "dir", type: .object)
        )

        let symbol = process("""
            <GETPT ,HERE .DIR>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: "here.property(dir)",
            type: .object.property
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("COUNT"),
                .property("STRENGTH")
            ], with: &localVariables).process()
        )
    }
}
