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

        let symbol = process("<REST STRUCT1>")

        XCTAssertNoDifference(symbol, .statement(
            code: "struct1.rest(bytes: 1)",
            type: .int.array
        ))
    }

    func testRestOfTable() throws {
        process("""
            <GLOBAL SOME-TABLE <TABLE 1 2 3 "4">>
        """)

        let symbol = process("<REST SOME-TABLE>")

        XCTAssertNoDifference(symbol, .statement(
            code: "someTable.rest(bytes: 1)",
            type: .table
        ))
    }

    func testRestOfMixedList() throws {
        process("""
            <GLOBAL STRUCT2 [1 2 "AB" "C"]>
        """)

        XCTAssertNoDifference(
            Game.findInstance("struct2"),
            Instance(Statement(
                id: "struct2",
                code: "var struct2: [TableElement] = []",
                type: .someTableElement.array,
                category: .globals,
                isCommittable: true
            ))
        )

        XCTAssertNoDifference(
            process("<REST STRUCT2>"),
            .statement(
                code: "struct2.rest(bytes: 1)",
                type: .someTableElement.array
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
                code: "struct3.rest(bytes: 2)",
                type: .someTableElement.array
            )
        )
    }
}
