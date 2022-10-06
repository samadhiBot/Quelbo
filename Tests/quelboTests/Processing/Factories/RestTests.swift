//
//  RestTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/17/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RestTests: QuelboTests {
    let factory = Factories.Rest.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("REST"))
    }

    func testRestOfIntegerList() throws {
        process("<GLOBAL STRUCT1 [1 2 3 4]>")

        let symbol = try factory.init([
            .atom("STRUCT1"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "struct1.rest()",
            type: .array(.int)
        ))
    }

    func testRestOfTable() throws {
        process("""
            <GLOBAL SOME-TABLE <TABLE 1 2 3 "4">>
        """)

        let symbol = try factory.init([
            .atom("SOME-TABLE"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "someTable.rest()",
            type: .table
        ))
    }

    func testRestOfMixedList() throws {
        process("""
            <GLOBAL STRUCT2 [1 2 "AB" "C"]>
        """)

        let symbol = try factory.init([
            .atom("STRUCT2"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(
            symbol,
            .statement(
                code: "struct2.rest()",
                type: .array(.zilElement)
            )
        )
    }

    func testRestOfMixedListAfterFirstTwo() throws {
        process(#"""
            <GLOBAL STRUCT3 [1 2 "AB" !\C]>
        """#)

        let symbol = try factory.init([
            .atom("STRUCT3"),
            .decimal(2)
        ], with: &localVariables).process()

        XCTAssertNoDifference(
            symbol,
            .statement(
                code: "struct3.rest(2)",
                type: .array(.zilElement)
            )
        )
    }
}
