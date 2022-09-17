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
        try Factories.Global([
            .atom("STRUCT1"),
            .vector([
                .decimal(1),
                .decimal(2),
                .decimal(3),
                .decimal(4)
            ])
        ], with: &localVariables).process()

        let symbol = try factory.init([
            .atom("STRUCT1"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "struct1.rest()",
            type: .array(.int)
        ))
    }

    func testRestOfTable() throws {
        try Factories.Global([
            .atom("SOME-TABLE"),
            .form([
                .atom("TABLE"),
                .decimal(1),
                .decimal(2),
                .decimal(3),
                .string("4"),
            ])
        ], with: &localVariables).process()

        let symbol = try factory.init([
            .atom("SOME-TABLE"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "someTable.rest()",
            type: .table
        ))
    }

    func testRestOfMixedList() throws {
        try Factories.Global([
            .atom("STRUCT2"),
            .vector([
                .decimal(1),
                .decimal(2),
                .string("AB"),
                .character("C"),
            ])
        ], with: &localVariables).process()

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
        try Factories.Global([
            .atom("STRUCT3"),
            .vector([
                .decimal(1),
                .decimal(2),
                .string("AB"),
                .character("C"),
            ])
        ], with: &localVariables).process()

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
