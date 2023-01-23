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

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("GETP"))
        AssertSameFactory(factory, Game.findFactory("GETPT"))
    }

    func testGetProperty() throws {
        let symbol = process("""
             <OBJECT TROLL>

             <GETP TROLL ,P?STRENGTH>
         """)

        XCTAssertNoDifference(symbol, .statement(
            code: "troll.strength",
            type: .int.property
        ))
    }

    func testGetPropertyReference() throws {
        let symbol = process("""
             <OBJECT TROLL>

             <GETPT ,TROLL ,P?STRENGTH>
         """)

        XCTAssertNoDifference(symbol, .statement(
            code: "troll.strength",
            type: .int.property
        ))
    }

    func testPropertyReferenceOfObjectInLocal() throws {
        let symbol = process("""
             <GLOBAL HERE 0>

             <GETPT ,HERE .DIR>
             """,
            with: [Statement(id: "dir", type: .object)]
        )

        XCTAssertNoDifference(symbol, .statement(
            code: "here.property(dir)",
            type: .unknown.property
        ))
    }
}
