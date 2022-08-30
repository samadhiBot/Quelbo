//
//  ListTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/4/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ListTests: QuelboTests {
    let factory = Factories.List.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("LIST"))
    }

    func testIntegerList() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(2),
            .decimal(3),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "[1, 2, 3]",
            type: .array(.int),
            confidence: .certain
        ))
    }

    func testStringList() throws {
        let symbol = try factory.init([
            .string("AB"),
            .string("CD"),
            .string("EF"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"["AB", "CD", "EF"]"#,
            type: .array(.string),
            confidence: .certain
        ))
    }

    func testMixedList() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(2),
            .string("AB"),
            .character("C"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "[1, 2, \"AB\", \"C\"]",
            type: .array(.zilElement),
            confidence: .certain
        ))
    }
}
