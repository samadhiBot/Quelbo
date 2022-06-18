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
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("LIST"))
    }

    func testIntegerList() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(2),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "[1, 2, 3]",
            type: .array(.int),
            children: [
                Symbol("1", type: .int, meta: [.isLiteral]),
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol("3", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testStringList() throws {
        let symbol = try factory.init([
            .string("AB"),
            .string("CD"),
            .string("EF"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"["AB", "CD", "EF"]"#,
            type: .array(.string),
            children: [
                Symbol("AB".quoted, type: .string, meta: [.isLiteral]),
                Symbol("CD".quoted, type: .string, meta: [.isLiteral]),
                Symbol("EF".quoted, type: .string, meta: [.isLiteral]),
            ]
        ))
    }

    func testMixedList() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(2),
            .string("AB"),
            .character("C"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "[1, 2, \"AB\", \"C\"]",
            type: .array(.zilElement),
            children: [
                Symbol("1", type: .int, meta: [.isLiteral]),
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol(#""AB""#, type: .string, meta: [.isLiteral]),
                Symbol(#""C""#, type: .string, meta: [.isLiteral]),
            ]
        ))
    }
}
